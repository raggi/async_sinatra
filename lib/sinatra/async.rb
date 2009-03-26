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

    private
    def aroute(*args, &block) #:nodoc:
      self.send :route, *args do |*bargs|
        mc = class << self; self; end
        mc.send :define_method, :__async_callback, &block
        EM.next_tick { send(:__async_callback, *bargs) }
        throw :async      
      end
    end

    module Helpers
      # Send the given body or block as the final response to the asynchronous 
      # request.
      def body(*args, &blk)
        super
        request.env['async.callback'][
          [response.status, response.headers, response.body]
        ] if respond_to?(:__async_callback)
      end
    end

    def self.registered(app) #:nodoc:
      app.helpers Helpers
    end
  end
end