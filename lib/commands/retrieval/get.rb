module Commands
  class Get
    def self.process_ret(values:, memcached:, socket:)
      values.each do |key|
        value = memcached[key]
        next if value.nil?

        bytes = value['bytes']
        data = value['data']
        socket.puts "VALUE #{key} #{value['flags']} #{bytes}\r\n"
        Marshal.dump("#{data}\r\n", socket, bytes)
      end
      socket.puts Messages::Messages::END_MESSAGE
    end
  end
end
