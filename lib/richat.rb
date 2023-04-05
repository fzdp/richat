require "richat/version"

require_relative 'richat/utils'
require_relative 'richat/config'
require_relative 'richat/command'
require_relative 'openai/chat'
require_relative 'richat/logger'
require_relative 'richat/shell'
require_relative 'richat/cli'

module Richat
  class Error < StandardError; end
end