module Commands
  class Add < Command
    def self.delete_after(time:, key:, memcached:)
      super
    end

    def self.process_sto(values:, memcached:, data: nil)
      key, flags, exptime, bytes, cas = values

      return cas unless memcached[key].nil?

      memcached[key] = { 'bytes' => bytes.to_i,
                         'cas' => cas,
                         'data' => data,
                         'flags' => flags.to_i }
      delete_after(time: exptime.to_i, key: key, memcached: memcached)
      cas + 1
    end
  end
end
