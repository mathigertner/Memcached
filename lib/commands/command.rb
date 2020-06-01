module Commands
  class Command
    def initialize(type)
      @type = type
    end

    def process_sto(values:, memcached:, data: nil)
      command.process_sto(values: values, memcached: memcached, data: data)
    end

    def process_ret(values:, memcached:, socket:)
      command.process_ret(values: values, memcached: memcached, socket: socket)
    end

    private

    def command
      Object.const_get("Commands::#{@type.capitalize}")
    end
  end
end
