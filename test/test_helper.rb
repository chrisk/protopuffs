# encoding: UTF-8

require 'rubygems'
require 'test/unit'

gem "polyglot", "=0.2.9"
gem "treetop", "=1.4.2"

gem "thoughtbot-shoulda", "=2.10.2"
require 'shoulda'

gem "mocha", "=0.9.8"
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'protopuffs'

class Test::Unit::TestCase

  # helper for debugging
  def print_bytes(string)
    puts
    string.each_byte do |byte|
      printf("%1$08b (%1$02X)\n", byte)
    end
  end

  # helper for generating test names
  def self.inspect_bytes(bytes_array)
    "[#{bytes_array.map { |b| sprintf("%02X", b) }.join(' ')}]"
  end


  def self.should_encode_wire_format_from_fields(expected_bytes, actual_fields)
    should "encode the fields #{actual_fields.inspect} to the byte string #{inspect_bytes(expected_bytes)}" do
      actual_fields.each_pair do |name, value|
        value = value.call if value.respond_to?(:call)
        @message.send("#{name}=", value)
      end
      actual_bytes = @message.to_wire_format.unpack('C*')
      assert_equal expected_bytes, actual_bytes
    end
  end

  def self.should_decode_wire_format_to_fields(actual_bytes, expected_fields)
    should "decode the byte string #{inspect_bytes(actual_bytes)} to the fields #{expected_fields.inspect}" do
      buffer = StringIO.new(actual_bytes.pack('C*'))
      buffer.set_encoding("BINARY") if buffer.respond_to?(:set_encoding)
      @message.from_wire_format(buffer)
      actual_fields = @message.class.fields.inject({}) { |hash, field|
        hash[field.identifier.to_sym] = @message.send(field.identifier)
        hash
      }

      expected_fields.each_pair do |key, expected_value|
        expected_value = expected_value.call if expected_value.respond_to?(:call)
        if expected_value.is_a?(Float)
          assert_in_delta(expected_value, actual_fields[key], Float::EPSILON)
        else
          assert_equal expected_value, actual_fields[key]
        end
      end

      assert_equal expected_fields.size, actual_fields.size
    end
  end

  def self.should_encode_and_decode_wire_format_and_fields(bytes, fields)
    self.should_encode_wire_format_from_fields(bytes, fields)
    self.should_decode_wire_format_to_fields(bytes, fields)
  end

  def self.should_losslessly_encode_and_decode_a_random_sample(fields)
    raise ArgumentError if fields.size > 1
    name, range = fields.shift
    should "get the same value back after encoding and decoding a random sample of the values #{range.inspect} for field #{name.inspect}" do
      size = range.last - range.first
      size -= 1 if range.exclude_end?
      values_to_test = [range.first, range.first + size]
      250.times { values_to_test << range.first + rand(size) }
      values_to_test.each do |value|
        @message.send("#{name}=", value)
        @message.from_wire_format(@message.to_wire_format)
        assert_equal value, @message.send(name)
      end
    end
  end

end

