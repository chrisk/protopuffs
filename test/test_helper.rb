require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'treetop'

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
      @message.from_wire_format(buffer)
      expected_fields.each_pair do |name, value|
        assert_equal value, @message.send(name)
      end
    end
  end


  def self.should_return_wire_type_for_fields_typed(wire_types)
    wire_types.each_pair do |wire_type, names|
      names.each do |name|
        should "return wire type #{wire_type} for a field with type #{name}" do
          assert_equal wire_type, Protopuffs::MessageField.new("required", name, "a", 1).wire_type
        end
      end
    end
  end

end

