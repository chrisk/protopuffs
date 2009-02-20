require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'treetop'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'protopuffs'

class Test::Unit::TestCase

  def print_bytes(string)
    puts
    string.each_byte do |byte|
      printf("%1$08b (%1$02X)\n", byte)
    end
  end

  def self.should_serialize_to_wire_format(*expected_bytes)
    should "serialize to the byte string [#{expected_bytes.map { |b| sprintf("%02X", b) }.join(' ')}]" do
      actual = @message.to_wire_format
      expected_bytes.each_with_index do |expected_byte, i|
        assert_equal actual[i], expected_byte
      end
    end
  end

end

