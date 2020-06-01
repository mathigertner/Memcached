module Utils
  def self.parameters_error?(line:)
    length = line.length
    cmd = line.first
    length < 2 || (cas?(cmd: cmd) && (![6, 7].include?(length) ||
      (length == 7 && !line[6].eql?('noreply')))) ||
      (!cas?(cmd: cmd) && belongs_to_sto?(cmd: cmd) && !([5, 6].include? length)) ||
      (belongs_to_ret?(cmd: cmd) && line.any? { |x| integer?(string: x) }) ||
      line[0..1].any? { |x| integer?(string: x) } || (length >= 3 &&
      line[2..length].any? { |x| !integer?(string: x) && !x.eql?('noreply') })
  end

  def self.cas?(cmd:)
    cmd.eql? Commands::CmdStoList::CAS
  end

  def self.integer?(string:)
    true if Integer(string) rescue false
  end

  def self.belongs_to_sto?(cmd:)
    Commands::CmdStoList::COMMANDS.include? cmd
  end

  def self.belongs_to_ret?(cmd:)
    Commands::CmdRetList::COMMANDS.include? cmd
  end
end
