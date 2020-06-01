module Commands
  class Command
    def self.delete_after(time:, key:, memcached:)
      return if time.zero?

      time = 0 if time.negative?
      Thread.new do
        sleep(time)
        memcached.delete(key)
      end
    end
  end
end
