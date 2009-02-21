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
      if @type == "bool"
        value = value ? 1 : 0
      end

      case wire_type
      # TODO: I feel some OO polymorphism coming on
      when WireType::VARINT
        value_bytes = self.class.varint_encode(value)
      when WireType::LENGTH_DELIMITED
        value_bytes = self.class.varint_encode(value.size)
        value_bytes += self.class.string_encode(value) if @type == "string"
        value_bytes += value if @type == "bytes"
      when WireType::FIXED32
        value_bytes = self.class.float_encode(value) if @type == "float"
      end

      tag_bytes = (@tag << 3) | wire_type

      output = StringIO.new
      output.write self.class.varint_encode(tag_bytes)
      output.write value_bytes
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

    def self.string_encode(value)
      value.unpack('U*').pack('C*')
    end

    def self.float_encode(value)
      [value].pack('e')
    end

    def wire_type
      case @type
      when "int32", "int64", "uint32", "uint64", "bool" then WireType::VARINT
      when "string", "bytes"                            then WireType::LENGTH_DELIMITED
      when "float"                                      then WireType::FIXED32
      end
    end
  end

end
