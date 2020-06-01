module Errors
  class ParametersError < StandardError
    def initialize(msg = "CLIENT_ERROR <parameters>\r\n")
      super
    end
  end
end
