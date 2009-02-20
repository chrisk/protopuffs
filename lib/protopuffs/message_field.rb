module Protopuffs

  class MessageField
    attr_reader :modifier, :type, :identifier, :tag, :default

    def initialize(modifier, type, identifier, tag, default = nil)
      @modifier = modifier
      @type = type
      @identifier = identifier
      @tag = tag
      @default = default
    end

    def to_wire_format_with_value(value)
      output = StringIO.new
      tag_bytes = (@tag << 3) | wire_type
      output.write self.class.varint_encode(tag_bytes)
      output.write self.class.varint_encode(value)
      output.string
    end

    def self.varint_encode(value)
      return [0].pack('C') if value.zero?
      bytes = []
      until value.zero?
        byte = 0
        7.times do |i|
          byte |= (value & 1) << i
          value >>= 1
        end
        byte |= 0b10000000
        bytes << byte
      end
      bytes[-1] &= 0b01111111
      bytes.pack('C*')
    end

    def wire_type
      case @type
      when "int32", "int64" then WireType::VARINT
      end
    end
  end

end
