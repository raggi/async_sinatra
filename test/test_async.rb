require 'minitest/autorun'

require 'eventmachine'

require "sinatra/async/test"

class CallbackCounter
  @@count = 0

  def self.count
    @@count
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    callback = env['async.callback']
    env['async.callback'] = lambda do |response|
      @@count += 1
      callback.call(response)
    end
    @app.call(env)
  end
end

class TestSinatraAsync < MiniTest::Unit::TestCase
  include Sinatra::Async::Test::Methods

  class TestApp < Sinatra::Base
    set :environment, :test
    set :call_count, 0

    register Sinatra::Async

    # Hack for storing some global data accessible in tests (normally you
    # shouldn't need to do this!)
    def self.singletons
      @singletons ||= []
    end

    error 401 do
      '401'
    end

    aget '/hello' do
      body { 'hello async' }
    end

    aget '/world' do
      body 'world'
    end

    aget '/em' do
      EM.add_timer(0.001) { body { 'em' }; EM.stop }
    end

    aget '/em_timeout' do
      # never send a response
    end

    aget '/404' do
      not_found
    end

    aget '/302' do
      ahalt 302
    end

    aget '/em_halt' do
      em_async_schedule { ahalt 404 }
    end

    aget '/s401' do
      halt 401
    end

    aget '/a401' do
      ahalt 401
    end

    aget '/async_close' do
      # don't call body here, the 'user' is going to 'disconnect' before we do
      env['async.close'].callback { self.class.singletons << 'async_closed' }
    end

    aget '/on_close' do
      # sugared version of the above
      on_close do
        self.class.singletons << 'async_close_cleaned_up'
      end
    end

    aget '/redirect' do
      redirect '/'
    end

    aget '/aredirect' do
      async_schedule { redirect '/' }
    end

    aget '/emredirect' do
      em_async_schedule { redirect '/' }
    end

    aget '/agents', :agent => /chrome/ do
      body { 'chrome' }
    end

    aget '/agents', :agent => /firefox/ do
     body { 'firefox' }
    end

    aget '/agents' do
      body { 'other' }
    end

    aget '/double_body_bug/:subdomain' do |subdomain|
      body { settings.call_count += 1; '' }
    end

    aget '/param/:a' do |ma|
      body { ma }
    end

    aget '/params/:a' do
      body { params[:a] }
    end

    aget '/params/deferred/:a' do
      async_schedule { body { aparams[:a] } }
    end

    aget '/halt-with-body' do
      async_schedule { ahalt 404, 'halted' }
    end

    apatch '/patch' do
      body { "apatch #{request.body.read}" }
    end

    # Defeat the test environment semantics, ensuring we actually follow the
    # non-test branch of async_schedule. You would normally just call
    # async_schedule in user apps, and use test helpers appropriately.
    def em_async_schedule
      o = self.class.environment
      self.class.set :environment, :normal
      async_schedule { yield }
    ensure
      self.class.set :environment, o
    end
  end

  def app
    Rack::Builder.new do
      use CallbackCounter
      run TestApp.new
    end.to_app
  end

  def assert_redirect(path)
    r = last_request.env
    uri = r['rack.url_scheme'] + '://' + r['SERVER_NAME'] + path
    assert_equal uri, last_response.location
  end

  def test_basic_async_get
    get '/hello'
    assert_async
    async_continue
    assert last_response.ok?
    assert_equal 'hello async', last_response.body
  end

  def test_em_get
    get '/em'
    assert_async
    em_async_continue
    assert last_response.ok?
    assert_equal 'em', last_response.body
  end

  def test_em_async_continue_timeout
    get '/em_timeout'
    assert_async
    assert_raises(MiniTest::Assertion) do
      em_async_continue(0.001)
    end
  end

  def test_404
    get '/404'
    assert_async
    async_continue
    assert_equal 404, last_response.status
  end

  def test_302
    get '/302'
    assert_async
    async_continue
    assert_equal 302, last_response.status
  end

  def test_em_halt
    get '/em_halt'
    assert_async
    em_async_continue
    assert_equal 404, last_response.status
  end

  def test_error_blocks_sync
    get '/s401'
    assert_async
    async_continue
    assert_equal 401, last_response.status
    assert_equal '401', last_response.body
  end

  def test_error_blocks_async
    get '/a401'
    assert_async
    async_continue
    assert_equal 401, last_response.status
    assert_equal '401', last_response.body
  end

  def test_async_close
    aget '/async_close'
    async_close
    assert_equal 'async_closed', TestApp.singletons.shift
  end

  def test_on_close
    aget '/on_close'
    async_close
    assert_equal 'async_close_cleaned_up', TestApp.singletons.shift
  end

  def test_redirect
    aget '/redirect'
    assert last_response.redirect?
    assert_equal 302, last_response.status
    assert_redirect '/'
  end

  def test_aredirect
    aget '/aredirect'
    assert last_response.redirect?
    assert_equal 302, last_response.status
    assert_redirect '/'
  end

  def test_emredirect
    aget '/emredirect'
    em_async_continue
    assert last_response.redirect?
    assert_equal 302, last_response.status
    assert_redirect '/'
  end

  def test_route_conditions_no_match
    aget '/agents'
    assert_equal 'other', last_response.body
  end

  def test_route_conditions_first
    header "User-Agent", "chrome"
    aget '/agents'
    assert_equal 'chrome', last_response.body
  end

  def test_route_conditions_second
    header "User-Agent", "firefox"
    aget '/agents'
    assert_equal 'firefox', last_response.body
  end

  def test_basic_async_head
    head '/hello'
    assert_async
    async_continue
    assert last_response.ok?
    assert_equal '', last_response.body
    assert_equal "11", last_response.headers['Content-Length']
  end

  def test_string_body
    get '/world'
    assert_async
    async_continue
    assert last_response.ok?
    assert_equal 'world', last_response.body
  end

  def test_double_body_bug
    aget '/double_body_bug/example'
    assert_equal 1, settings.call_count
  end

  def test_block_with_no_args
    aget '/params/test'
    assert_equal 'test', last_response.body
  end

  def test_block_with_an_arg
    aget '/param/test'
    assert_equal 'test', last_response.body
  end

  def test_params_deferred
    aget '/params/deferred/test'
    assert_equal 'test', last_response.body
  end

  def test_two_requests
    aget '/hello'
    assert last_response.ok?
    aget '/302'
    assert_equal 302, last_response.status
  end

  def test_bug_42_halt_with_body_should_only_call_callback_once
    start = CallbackCounter.count
    aget '/halt-with-body'
    assert_equal 'halted', last_response.body
    assert_equal start + 1, CallbackCounter.count
  end

  def test_apatch
    apatch "/patch", "body for apatch", { "CONTENT_TYPE" => "text/plain" }
    assert_equal 200, last_response.status
    assert_equal "apatch body for apatch", last_response.body
  end
end
