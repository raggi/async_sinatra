gem 'test-unit'
require "test/unit"
require 'rack/test'

require 'eventmachine'

require "sinatra/async"

class TestSinatraAsync < Test::Unit::TestCase
  include Sinatra::Async::Test::Methods

  class TestApp < Sinatra::Base
    set :environment, :test
    register Sinatra::Async

    error 401 do
      '401'
    end

    aget '/hello' do
      body { 'hello async' }
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
      EM.next_tick { ahalt 404 }
    end

    aget '/s401' do
      halt 401
    end

    aget '/a401' do
      ahalt 401
    end
  end

  def app
    TestApp.new
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
    assert_raises(Test::Unit::AssertionFailedError) do
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
end