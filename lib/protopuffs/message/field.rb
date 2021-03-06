# encoding: UTF-8

module Protopuffs

  class MessageField
    attr_reader :identifier, :tag, :default

    def self.factory(type, *args)
      case type
      when "int32"    then Int32.new(*args)
      when "int64"    then Int64.new(*args)
      when "uint32"   then UInt32.new(*args)
      when "uint64"   then UInt64.new(*args)
      when "bool"     then Bool.new(*args)
      when "double"   then Double.new(*args)
      when "fixed64"  then Fixed64.new(*args)
      when "string"   then String.new(*args)
      when "bytes"    then Bytes.new(*args)
      when "float"    then Float.new(*args)
      when "fixed32"  then Fixed32.new(*args)
      when "sfixed32" then SFixed32.new(*args)
      else Embedded.new(type, *args)
      end
    end

    def initialize(modifier, identifier, tag, default)
      raise "MessageField is an abstract base class" if self.class == MessageField
      raise ArgumentError.new("Invalid modifier '#{modifier}'") unless
        ["optional", "required", "repeated"].include?(modifier)
      @modifier = modifier
      @identifier = identifier
      @tag = tag
      @default = default
    end
    private :initialize

    def key
      (@tag << 3) | self.class.wire_type
    end

    def repeated?
      @modifier == "repeated"
    end

    def optional?
      @modifier == "optional"
    end

    def to_wire_format_with_value(value)
      field_encoder = lambda { |val| VarInt.encode(key) + self.class.encode(val) }
      if repeated?
        value.map(&field_encoder).join
      else
        field_encoder.call(value)
      end
    end

    def self.shift_tag(buffer)
      bits = 0
      bytes = VarInt.shift(buffer)
      bytes.each_with_index do |byte, index|
        byte &= 0b01111111
        bits |= byte << (7 * index)
      end
      bits >> 3
    end
  end

  class Bool < MessageField
    def initialize(modifier, identifier, tag, default = nil)
      super(modifier, identifier, tag, default || false)
    end
    def self.wire_type;     WireType::VARINT end
    def self.shift(buffer); VarInt.shift(buffer) end
    def decode(value_bytes)
      value = VarInt.decode(value_bytes)
      value = true  if value == 1
      value = false if value == 0
      value
    end
    def self.encode(value); VarInt.encode(value ? 1 : 0) end
  end

  class Numeric < MessageField
    def initialize(modifier, identifier, tag, default = nil)
      super(modifier, identifier, tag, default || 0)
    end
  end

  class VarInt < Numeric
    def self.wire_type; WireType::VARINT end
    def self.shift(buffer)
      bytes = []
      begin
        # Use #readbyte in Ruby 1.9, and #readchar in Ruby 1.8
        byte = buffer.send(buffer.respond_to?(:readbyte) ? :readbyte : :readchar)
        bytes << (byte & 0b01111111)
      end while byte >> 7 == 1
      bytes
    end
    def self.decode(bytes)
      value = 0
      bytes.each_with_index do |byte, index|
        value |= byte << (7 * index)
      end
      value
    end
    def decode(bytes)
      VarInt.decode(bytes)
    end
    def self.encode(value)
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
  end

  class Int32 < VarInt; end
  class Int64 < VarInt; end
  class UInt32 < VarInt; end
  class UInt64 < VarInt; end

  class Fixed32Base < Numeric
    def self.wire_type;     WireType::FIXED32 end
    def self.shift(buffer); buffer.read(4) end
  end

  class Fixed32 < Fixed32Base
    def decode(bytes);      bytes.unpack('V').first end
    def self.encode(value); [value].pack('V') end
  end

  class SFixed32 < Fixed32Base
    def decode(bytes)
      value = bytes.unpack('V').first
      value >= 2**31 ? value -= 2**32 : value
    end
    def self.encode(value); [value].pack('V') end
  end

  class Float < Fixed32Base
    def decode(bytes);      bytes.unpack('e').first end
    def self.encode(value); [value].pack('e') end
  end

  class Fixed64Base < Numeric
    def self.wire_type;     WireType::FIXED64 end
    def self.shift(buffer); buffer.read(8) end
  end

  class Fixed64 < Fixed64Base
    def decode(bytes);      bytes.unpack('Q').first end
    def self.encode(value); [value].pack('Q') end
  end

  class Double < Fixed64Base
    def decode(bytes);      bytes.unpack('E').first end
    def self.encode(value); [value].pack('E') end
  end

  class LengthDelimited < MessageField
    def self.wire_type; WireType::LENGTH_DELIMITED end
    def self.shift(buffer)
      bytes = VarInt.shift(buffer)
      value_length = VarInt.decode(bytes)
      buffer.read(value_length)
    end
    def decode(bytes); bytes end
  end

  class String < LengthDelimited
    def initialize(modifier, identifier, tag, default = nil)
      super(modifier, identifier, tag, default || "")
    end
    def self.encode(value)
      value = value.to_s
      value.force_encoding("UTF-8") if value.respond_to?(:force_encoding)
      # Use #bytesize in Ruby 1.9, and #size in Ruby 1.8
      size = value.respond_to?(:bytesize) ? value.bytesize : value.size
      VarInt.encode(size) + value
    end
    def decode(bytes)
      bytes.respond_to?(:force_encoding) ? bytes.force_encoding("UTF-8") : bytes
    end
  end

  class Bytes < LengthDelimited
    def initialize(modifier, identifier, tag, default = nil)
      super
    end
    def self.encode(value)
      VarInt.encode(value.size) + value
    end
    def decode(bytes)
      bytes.respond_to?(:force_encoding) ? bytes.force_encoding("BINARY") : bytes
    end
  end

  class Embedded < LengthDelimited
    def initialize(type, modifier, identifier, tag, default = nil)
      @type = type
      super(modifier, identifier, tag, default)
    end
    def decode(bytes)
      bytes.force_encoding("BINARY") if bytes.respond_to?(:force_encoding)
      value = Message.const_get(@type.delete("_")).new
      value.from_wire_format(StringIO.new(bytes))
    end
    def self.encode(value)
      embedded_bytes = value.to_wire_format
      VarInt.encode(embedded_bytes.size) + embedded_bytes
    end
  end

end

