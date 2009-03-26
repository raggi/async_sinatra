# Normally Sinatra::Base expects that the completion of a request is 
# determined by the block exiting, and returning a value for the body.
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
module Sinatra::Async
  module ClassMethods
    def aget(path, opts={}, &block)
      conditions = @conditions.dup
      aroute('GET', path, opts, &block)

      @conditions = conditions
      aroute('HEAD', path, opts, &block)
    end

    def aput(path, opts={}, &bk); aroute 'PUT', path, opts, &bk; end
    def apost(path, opts={}, &bk); aroute 'POST', path, opts, &bk; end
    def adelete(path, opts={}, &bk); aroute 'DELETE', path, opts, &bk; end
    def ahead(path, opts={}, &bk); aroute 'HEAD', path, opts, &bk; end

    private
    def aroute(*args, &block)
      self.send :route, *args do |*bargs|
        mc = class << self; self; end
        mc.send :define_method, :__async_callback, &block
        EM.next_tick { send(:__async_callback, *bargs) }
        throw :async      
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  def body(*args, &blk)
    super
    request.env['async.callback'][[response.status, response.headers, response.body]]
  end
end