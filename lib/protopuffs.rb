require "rubygems"
require "treetop"
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

  def self.load_message_classes
    parser = Protopuffs::Parser::ProtocolBufferDescriptor.new

    @proto_load_path.each do |path|
      Dir.glob(File.join(path, "**/*.proto")) do |descriptor_path|
        parser.parse(File.read(descriptor_path))
      end
    end
  end
end
