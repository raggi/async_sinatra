require 'sinatra/base'

module Sinatra #:nodoc:

  # Normally Sinatra expects that the completion of a request is # determined
  # by the block exiting, and returning a value for the body.
  #
  # In an async environment, we want to tell the webserver that we're not going
  # to provide a response now, but some time in the future.
  #
  # The a* methods provide a method for doing this, by informing the server of
  # our asynchronous intent, and then scheduling our action code (your block)
  # as the next thing to be invoked by the server.
  #
  # This code can then do a number of things, including waiting (asynchronously)
  # for external servers, services, and whatnot to complete. When ready to send
  # the real response, simply setup your environment as you normally would for 
  # sinatra (using #content_type, #headers, etc). Finally, you complete your
  # response body by calling the #body method. This will push your body into the
  # response object, and call out to the server to actually send that data.
  #
  # == Example
  #  require 'sinatra/async'
  #  
  #  class AsyncTest < Sinatra::Base
  #    register Sinatra::Async
  #  
  #    aget '/' do
  #      body "hello async"
  #    end
  #  
  #    aget '/delay/:n' do |n|
  #      EM.add_timer(n.to_i) { body { "delayed for #{n} seconds" } }
  #    end
  #  
  #  end
  module Async

    # Similar to Sinatra::Base#get, but the block will be scheduled to run
    # during the next tick of the EventMachine reactor. In the meantime,
    # Thin will hold onto the client connection, awaiting a call to 
    # Async#body with the response.
    def aget(path, opts={}, &block)
      conditions = @conditions.dup
      aroute('GET', path, opts, &block)

      @conditions = conditions
      aroute('HEAD', path, opts, &block)
    end

    # See #aget.
    def aput(path, opts={}, &bk); aroute 'PUT', path, opts, &bk; end
    # See #aget.
    def apost(path, opts={}, &bk); aroute 'POST', path, opts, &bk; end
    # See #aget.
    def adelete(path, opts={}, &bk); aroute 'DELETE', path, opts, &bk; end
    # See #aget.
    def ahead(path, opts={}, &bk); aroute 'HEAD', path, opts, &bk; end
    # See #aget
    def aoptions(path, opts={}, &bk); aroute 'OPTIONS', path, opts, &bk; end
    # See #aget
    def apatch(path, opts={}, &bk); aroute 'PATCH', path, opts, &bk; end
    # See #aget
    def alink(path, opts={}, &bk); aroute 'LINK', path, opts, &bk; end
    # See #aget
    def aunlink(path, opts={}, &bk); aroute 'UNLINK', path, opts, &bk; end


    private
    def aroute(verb, path, opts = {}, &block) #:nodoc:
      method = :"A#{verb} #{path} #{opts.hash}"
      define_method method, &block

      route(verb, path, opts) do |*bargs|
        async_runner(method, *bargs)
        async_response
      end
    end

    module Helpers
      # aparams are used when inside of something that has been scheduled
      # asynchronously in an asynchronous route. Essentially it is the last
      # parameters to be set by the router (for example, containing the route
      # captures).
      attr_reader :aparams

      # Send the given body or block as the final response to the asynchronous 
      # request.
      def body(value = nil)
        if @async_running && (value || block_given?)
          if block_given?
            super { async_handle_exception { yield } }
          else
            super
          end

          if response.body.respond_to?(:call)
            response.body = Array(async_handle_exception {response.body.call})
          end

          # Taken from Base#call
          unless @response['Content-Type']
            if Array === body and body[0].respond_to? :content_type
              content_type body[0].content_type
            else
              content_type :html
            end
          end

          result = response.finish

          # We don't get the HEAD middleware, so just do something convenient
          # here.
          result[-1] = [] if request.head?

          request.env['async.callback'][ result ]
          body
        else
          super
        end
      end

      # async_schedule is used to schedule work in a future context, the block
      # is wrapped up so that exceptions and halts (redirect, etc) are handled
      # correctly.
      def async_schedule(&b)
        if settings.environment == :test
          settings.set :async_schedules, [] unless settings.respond_to? :async_schedules
          settings.async_schedules << lambda { async_catch_execute(&b) }
        else
          native_async_schedule { async_catch_execute(&b) }
        end
      end

      # By default native_async_schedule calls EventMachine#next_tick, if
      # you're using threads or some other scheduling mechanism, it must take
      # the block passed here and schedule it for running in the future.
      def native_async_schedule(&b)
        EM.next_tick(&b)
      end

      # Defaults to throw async as that is most commonly used by servers.
      def async_response
        throw :async
      end

      def async_runner(meth, *bargs)
        @aparams = @params.dup
        async_schedule do
          begin
            original, @params = @params, @aparams
            method(meth).arity == 0 ? send(meth) : send(meth, *bargs)
          ensure
            @params = original
          end
          nil
        end
      end

      def async_catch_execute(&b)
        @async_running = true
        async_handle_exception do
          if h = catch(:halt, &b)
            invoke { halt h }
            invoke { error_block! response.status }
            body(response.body)
          end
        end
      end

      def async_handle_exception
        yield
      rescue ::Exception => boom
        if settings.show_exceptions?
          printer = Sinatra::ShowExceptions.new(proc{ raise boom })
          s, h, b = printer.call(request.env)
          response.status = s
          response.headers.replace(h)
          response.body = b
          body(response.body)
        else
          body(handle_exception!(boom))
        end
      end

      # Asynchronous halt must be used when the halt is occuring outside of
      # the original call stack.
      def ahalt(*args)
        invoke { halt(*args) }
        invoke { error_block! response.status }
        body response.body
      end

      # The given block will be executed if the user closes the connection
      # prematurely (before we've sent a response). This is good for
      # deregistering callbacks that would otherwise send the body (for
      # example channel subscriptions).
      def on_close(&blk)
        env['async.close'].callback(&blk)
      end
    end

    def self.registered(app) #:nodoc:
      app.helpers Helpers
    end
  end
end
