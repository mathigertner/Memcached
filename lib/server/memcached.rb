require_relative './server'

module Memcached
  Server.new('localhost', 8080)
end
