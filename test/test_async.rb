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

    aget '/hello' do
      body { 'hello async' }
    end

    aget '/em' do
      EM.add_timer(0.001) { body { 'em' }; EM.stop }
    end

    aget '/em_timeout' do
      # never send a response
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

end