require'bundler'
Bundler.require
require'json'
require'pry'

RSpec.configure do |c|
  c.color = true
end

require 'double_serializer'
include DoubleSerializer

require 'double_dispatcher_shared'

