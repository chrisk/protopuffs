require "protopuffs/message_field"
require "protopuffs/parser"

module Protopuffs
  def self.proto_load_path
    @proto_load_path ||= []
  end
end
