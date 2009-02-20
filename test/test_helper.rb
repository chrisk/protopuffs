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
      actual_bytes = @message.to_wire_format.unpack('C*')
      assert_equal actual_bytes, expected_bytes
    end
  end

end

