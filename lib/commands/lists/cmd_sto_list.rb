module Commands
  class CmdStoList
    COMMANDS = %w[set add replace append prepend cas].freeze
    CAS = 'cas'.freeze
  end
end
