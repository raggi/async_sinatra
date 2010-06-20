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

  aget '/araise' do
    EM.add_timer(1) { body { raise "boom" } }
  end

  # This will blow up in thin currently
  aget '/raise/die' do
    EM.add_timer(1) { raise 'die' }
  end

end

run AsyncTest.new
