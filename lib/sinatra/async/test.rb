require 'rack/test'

class Rack::MockResponse
  def async?
    self.status == -1
  end
end

class Sinatra::Async::Test
  class AsyncSession < Rack::MockSession
    def request(uri, env)
      env['async.callback'] = lambda { |r| s,h,b = *r; handle_last_response(uri, env, s,h,b) }
      env['async.close'] = lambda { raise 'close connection' } # XXX deal with this
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
  end

  module Methods
    include Rack::Test::Methods
    
    %w(get put post delete head).each do |m|
      eval <<-RUBY, binding, __FILE__, __LINE__
        def a#{m}(*args)
          #{m} *args
          assert_async
          async_continue
        end
      RUBY
    end

    def build_rack_mock_session # XXX move me
      Sinatra::Async::Test::AsyncSession.new(app)
    end

    def assert_async
      assert last_response.async?
    end

    def async_continue
      while b = app.options.async_schedules.shift
        b.call
      end
    end

    def em_async_continue(timeout = 10)
      timed = false
      EM.run do
        async_continue
        EM.tick_loop { EM.stop unless last_response.async? }
        EM.add_timer(timeout) { timed = true; EM.stop }
      end
      assert !timed, "asynchronous timeout after #{timeout} seconds"
    end
  end
end