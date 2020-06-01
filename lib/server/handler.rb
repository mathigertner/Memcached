require 'socket'
require_relative '../messages/messages'
require_relative '../commands/command'
require_relative '../utils/utils'
Dir['../commands/lists/*.rb'].sort.each { |file| require file }
Dir['../commands/storage/*.rb'].sort.each { |file| require file }
Dir['../commands/retrieval/*.rb'].sort.each { |file| require file }
Dir['../errors/*.rb'].sort.each { |file| require file }

module Memcached
  class Handler
    def initialize(socket)
      @socket = socket
      @memcached = {}
      @cas = 1
    end

    def run
      loop do
        response = @socket.gets.chomp
        validate_params(line: response.split)
        assign_params(line: response.split)
        process
      rescue StandardError => e
        if !server_error?(error: e)
          send(message: e.message)
        else
          send(message: "#{Messages::Messages::SERVER_ERROR} <#{e.message}>")
          @socket.close
        end
      end
    end

    def server_error?(error:)
      !(error.is_a?(Errors::ParametersError) || error.is_a?(Errors::CommandError))
    end

    def process
      if Utils.belongs_to_sto?(cmd: @cmd)
        process_sto
      elsif Utils.belongs_to_ret?(cmd: @cmd)
        process_ret
      end
    end

    def process_sto
      data = receive_data
      pre_processed = deep_copy(obj: @memcached)
      save_data(data: data)
      return unless send_response?

      send_response(old_hash: pre_processed, new_hash: @memcached)
    end

    def send_response?
      !Utils.cas?(cmd: @cmd) && !@noreply
    end

    def deep_copy(obj:)
      Marshal.load(Marshal.dump(obj))
    end

    def receive_data
      Marshal.load(@socket)[0..@bytes - 1]
    end

    def send(message:)
      @socket.puts message
    end

    def validate_params(line:)
      cmd = line.first
      cmd_error unless Utils.belongs_to_sto?(cmd: cmd) || Utils.belongs_to_ret?(cmd: cmd)
      parameters_error if Utils.parameters_error?(line: line)
    end

    def cmd_error
      raise Errors::CommandError
    end

    def parameters_error
      raise Errors::ParametersError
    end

    def assign_params(line:)
      @cmd = line[0]
      @params = line.slice(1, line.length)
      @key = @params.first
      @exptime = @params[2].to_i
      @bytes = @params[3].to_i
      @noreply = noreply?
      @params.delete('noreply') if @noreply
    end

    def noreply?
      (Utils.belongs_to_sto?(cmd: @cmd) &&
        !Utils.cas?(cmd: @cmd) && @params.length == 5 && @params[4].eql?('noreply')) ||
        (Utils.cas?(cmd: @cmd) && @params.length == 6 && @params[5].eql?('noreply'))
    end

    def send_response(old_hash:, new_hash:)
      if old_hash.eql? new_hash
        send(message: Messages::Messages::NOT_STORED)
      else
        send(message: Messages::Messages::STORED)
      end
    end

    def command
      Commands::Command.new(@cmd)
    end

    def save_data(data:)
      values = deep_copy(obj: @params)
      Utils.cas?(cmd: @cmd) ? values.push(@socket, @noreply) : values.push(@cas)
      cas = command.process_sto(values: values, memcached: @memcached, data: data)
      @cas = cas unless Utils.cas?(cmd: @cmd)
    end

    def process_ret
      command.process_ret(values: @params, memcached: @memcached, socket: @socket)
    end
  end
end
