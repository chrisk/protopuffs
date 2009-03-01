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

    def wire_type
      case @type
      when "int32", "int64", "uint32", "uint64", "bool" then WireType::VARINT
      when "double", "fixed64"                          then WireType::FIXED64
      when "string", "bytes"                            then WireType::LENGTH_DELIMITED
      when "float", "fixed32"                           then WireType::FIXED32
      else WireType::LENGTH_DELIMITED # embedded messages
      end
    end

    def key
      (@tag << 3) | wire_type
    end

    def repeated?
      @modifier == "repeated"
    end

    def to_wire_format_with_value(value)
      field_encoder = lambda { |val| self.class.varint_encode(key) + encode(val) }

      if repeated?
        value.map(&field_encoder).join
      else
        field_encoder.call(value)
      end
    end

    def encode(value)
      case wire_type
      when WireType::VARINT
        value = (value ? 1 : 0) if @type == "bool"
        value_bytes = self.class.varint_encode(value)
      when WireType::LENGTH_DELIMITED
        if value.respond_to?(:to_wire_format)
          embedded_bytes = value.to_wire_format
          value_bytes = self.class.varint_encode(embedded_bytes.size) + embedded_bytes
        else
          value_bytes = self.class.varint_encode(value.size)
          value_bytes += self.class.string_encode(value) if @type == "string"
          value_bytes += value if @type == "bytes"
        end
      when WireType::FIXED32
        value_bytes = self.class.float_encode(value) if @type == "float"
        value_bytes = self.class.fixed32_encode(value) if @type == "fixed32"
      when WireType::FIXED64
        value_bytes = self.class.double_encode(value) if @type == "double"
        value_bytes = self.class.fixed64_encode(value) if @type == "fixed64"
      end
      value_bytes
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

    def self.double_encode(value)
      [value].pack('E')
    end

    def self.fixed64_encode(value)
      [value].pack('Q')
    end

    def self.fixed32_encode(value)
      [value].pack('V')
    end
  end

end
