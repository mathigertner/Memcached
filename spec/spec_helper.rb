require_relative '../lib/commands/storage/command'
require_relative '../lib/commands/storage/add'
require_relative '../lib/commands/storage/append'
require_relative '../lib/commands/storage/prepend'
require_relative '../lib/commands/storage/replace'
require_relative '../lib/commands/storage/set'
require_relative '../lib/commands/storage/cas'
require_relative '../lib/commands/retrieval/get'
require_relative '../lib/commands/retrieval/gets'
require_relative '../lib/commands/lists/cmd_sto_list'
require_relative '../lib/commands/lists/cmd_ret_list'
require_relative '../lib/errors/command_error'
require_relative '../lib/errors/parameters_error'
require_relative '../lib/server/handler'
require_relative '../lib/server/server'

RSpec.configure do |config|
  config.color = true
end
