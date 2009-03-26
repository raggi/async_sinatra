#!/usr/bin/env rackup -Ilib:../lib -s thin
require 'sinatra/async'

class AsyncTest < Sinatra::Base
  register Sinatra::Async

  aget '/' do
    body "hello async"
  end

  aget '/delay/:n' do |n|
    EM.add_timer(n.to_i) { body { "delayed for #{n} seconds" } }
  end

end

run AsyncTest.new