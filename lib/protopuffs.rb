require "protopuffs/message/base"
require "protopuffs/message/field"
require "protopuffs/message/wire_type"
require "protopuffs/parser/parser"


module Protopuffs
  class ParseError < StandardError; end

  def self.proto_load_path
    @proto_load_path ||= []
  end

  def self.proto_load_path=(paths)
    @proto_load_path = paths
  end
end
