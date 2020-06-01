module Errors
  class CommandError < StandardError
    def initialize(msg = "ERROR\r\n")
      super
    end
  end
end
