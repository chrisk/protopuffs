require "protopuffs/message_descriptor"
require "protopuffs/message_field"
require "protopuffs/parser"
require "protopuffs/wire_type"

module Protopuffs
  class ParseError < StandardError; end

  def self.proto_load_path
    @proto_load_path ||= []
  end
end
