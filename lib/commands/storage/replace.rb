module Commands
  class Replace < Command
    def self.delete_after(time:, key:, memcached:)
      super
    end

    def self.process_sto(values:, memcached:, data: nil)
      key, flags, exptime, bytes, cas = values

      return cas if memcached[key].nil?

      value = memcached[key]
      value['bytes'] = bytes.to_i
      value['data'] = data
      value['flags'] = flags.to_i
      delete_after(time: exptime.to_i, key: key, memcached: memcached)
      cas
    end
  end
end
