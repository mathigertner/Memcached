require 'socket'
require_relative './handler'

module Memcached
  class Server
    def initialize(socket_address, socket_port)
      @server_socket = TCPServer.open(socket_address, socket_port)
      start
    end

    def start
      loop do
        client = @server_socket.accept
        Thread.start(client) do |conn|
          handler = Handler.new(conn)
          handler.run
        end
      end
    end
  end
  Thread.new do
    Server.new('localhost', 8080)
  end
end
