module Commands
  class Cas < Command
    def self.delete_after(time:, key:, memcached:)
      super
    end

    def self.cas_match?(value:)
      value['cas'].eql? @cas.to_i
    end

    def self.check(value:)
      if value.nil?
        Messages::Messages::NOT_FOUND
      elsif !cas_match?(value: value)
        Messages::Messages::EXISTS
      end
    end

    def self.process_sto(values:, memcached:, data:)
      @key, @flags, exptime, @bytes, @cas, @socket, @noreply = values
      msg = check(value: memcached[@key])
      unless msg.nil?
        @socket.puts msg unless @noreply
        return
      end
      update(memcached: memcached, data: data)
      delete_after(time: exptime.to_i, key: @key, memcached: memcached)
    end

    def self.update(memcached:, data:)
      value = memcached[@key]
      value['bytes'] = @bytes.to_i
      value['data'] = data
      value['flags'] = @flags.to_i
      @socket.puts Messages::Messages::STORED unless @noreply
    end
  end
end
