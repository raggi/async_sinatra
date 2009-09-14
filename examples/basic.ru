#!/usr/bin/env rackup -Ilib:../lib -s thin
require 'sinatra/async'

class AsyncTest < Sinatra::Base
  register Sinatra::Async

  enable :show_exceptions

  aget '/' do
    body "hello async"
  end

  aget '/delay/:n' do |n|
    EM.add_timer(n.to_i) { body { "delayed for #{n} seconds" } }
  end

  aget '/raise' do
    raise 'boom'
  end

end

run AsyncTest.new
