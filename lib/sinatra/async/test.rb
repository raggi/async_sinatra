require 'sinatra/async'
require 'rack/test'

class Rack::MockResponse
  def async?
    self.status == -1
  end
end

class Sinatra::Async::Test

  class AsyncSession < Rack::MockSession
    class AsyncCloser
      def initialize
        @callbacks, @errbacks = [], []
      end
      def callback(&b)
        @callbacks << b
      end
      def errback(&b)
        @errbacks << b
      end
      def fail
        @errbacks.each { |cb| cb.call }
        @errbacks.clear
      end
      def succeed
        @callbacks.each { |cb| cb.call }
        @callbacks.clear
      end
    end

    def request(uri, env)
      env['async.callback'] = lambda { |r| s,h,b = *r; handle_last_response(uri, env, s,h,b) }
      env['async.close'] = AsyncCloser.new
      catch(:async) { super }
      @last_response ||= Rack::MockResponse.new(-1, {}, [], env["rack.errors"].flush)
    end

    def handle_last_response(uri, env, status, headers, body)
      @last_response = Rack::MockResponse.new(status, headers, body, env["rack.errors"].flush)
      body.close if body.respond_to?(:close)

      cookie_jar.merge(last_response.headers["Set-Cookie"], uri)

      @after_request.each { |hook| hook.call }
      @last_response
    end

    def reset_last_response
      @last_response = nil
    end
  end

  module Methods
    include Rack::Test::Methods

    %w(get put post delete head options patch).each do |m|
      eval <<-RUBY, binding, __FILE__, __LINE__ + 1
      def a#{m}(*args)
        rack_mock_session.reset_last_response
        #{m}(*args)
        assert_async
        async_continue
      end
      RUBY
    end

    def build_rack_mock_session # XXX move me
      Sinatra::Async::Test::AsyncSession.new(app)
    end

    def assert_async
      assert last_response.async?, "response not asynchronous. expected a status of -1 got #{last_response.status}"
    end

    # Simulate a user closing the connection before a response is sent.
    def async_close
      raise ArgumentError, 'please make a request first' unless last_request
      current_session.last_request.env['async.close'].succeed
    end

    # Executes the pending asynchronous blocks, required for the
    # aget/apost/etc blocks to run.
    def async_continue
      while b = settings.async_schedules.shift
        b.call
      end
    end

    def settings
      # This hack exists because sinatra is now returning a proper rack stack.
      # We might need to consider alternative approaches in future.
      app = app()
      app = app.app if app.is_a?(Sinatra::ExtendedRack)

      until app.nil? || app.is_a?(Sinatra::Base) || app.is_a?(Sinatra::Wrapper)
        app = app.instance_variable_get(:@app)
      end
      raise "Cannot determine sinatra application from #{app()}" unless app
      app.settings
    end

    # Crank the eventmachine loop until a response is made, or timeout after a
    # particular period, by default 10s. If the timeout is nil, no timeout
    # will occur.
    def em_async_continue(timeout = 10)
      timed = false
      EM.run do
        async_continue
        em_hard_loop { EM.stop unless last_response.async? }
        EM.add_timer(timeout) { timed = true; EM.stop } if timeout
      end
      assert !timed, "asynchronous timeout after #{timeout} seconds"
    end

    # Uses EM.tick_loop or a periodic timer to check for changes
    def em_hard_loop
      if EM.respond_to?(:tick_loop)
        EM.tick_loop { yield }
      else
        EM.add_periodic_timer(0.0001) { yield }
      end
    end
  end
end
