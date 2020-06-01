module Commands
  class Gets
    def self.process_ret(values:, memcached:, socket:)
      values.each do |key|
        value = memcached[key]
        next if value.nil?

        bytes = value['bytes']
        cas = value['cas']
        socket.puts "VALUE #{key} #{value['flags']} #{bytes} #{cas}\r\n"
        Marshal.dump("#{value['data']}\r\n", socket, bytes)
      end
      socket.puts Messages::Messages::END_MESSAGE
    end
  end
end
