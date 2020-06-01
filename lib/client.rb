require 'socket'
require './commands/lists/cmd_sto_list'
require './commands/lists/cmd_ret_list'
require './utils/utils'

module Memcached
  class Client
    def initialize(socket)
      @socket = socket
      @request_object = send_request
      @response_object = listen_response
      @request_object.join # will send the request to server
      @response_object.join # will receive response from server
    end

    def send
      message = $stdin.gets.chomp
      line = message.split
      limit = line[4].to_i
      @socket.puts "#{message}\r\n"
      send_bytes(limit: limit) if send_bytes?(line: line)
    end

    def send_bytes?(line:)
      cmd = line[0]
      Commands::CmdStoList::COMMANDS.include?(cmd) && !Utils.parameters_error?(line: line)
    end

    def send_bytes(limit:)
      message = "#{$stdin.gets.chomp}\r\n"
      Marshal.dump(message, @socket, limit)
    end

    def receive_data(bytes:)
      puts Marshal.load(@socket)[0..bytes - 1]
    end

    def receive_data?(response:)
      response.split.first.eql?('VALUE')
    end

    def send_request
      Thread.new do
        loop do
          send
        end
      end
    rescue IOError => e
      puts e.message
      # e.backtrace
      @socket.close
    end

    def listen_response
      Thread.new do
        loop do
          response = @socket.gets.chomp
          puts response
          receive_data(bytes: response.split[3].to_i) if receive_data?(response: response)
        end
      end
    rescue IOError => e
      puts e.message
      # e.backtrace
      @socket.close
    end
  end
  socket = TCPSocket.open('localhost', 8080)
  Client.new(socket)
end
