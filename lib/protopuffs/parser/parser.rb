module Protopuffs

  # The Protopuffs::Parser module holds wrapper classes that parse input
  # strings using Treetop. They also set off the building of an abstract
  # syntax tree from Treetop's parse tree.
  module Parser

    class ProtocolBufferDescriptor
      def initialize
        Treetop.load "lib/protopuffs/parser/protocol_buffer"
        @parser = Protopuffs::ProtocolBufferParser.new
      end

      def parse(input)
        parse_tree = @parser.parse(input)
        parse_tree.build
        parse_tree
      rescue
        raise ParseError
      end
    end

  end
end