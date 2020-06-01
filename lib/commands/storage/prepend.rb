module Commands
  class Prepend < Command
    def self.process_sto(values:, memcached:, data: nil)
      key, _, _, bytes, cas = values

      return cas if memcached[key].nil?

      value = memcached[key]
      value['bytes'] = value['bytes'] + bytes.to_i
      value['data'] = "#{data}#{value['data']}"
      cas
    end
  end
end
