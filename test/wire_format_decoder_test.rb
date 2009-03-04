require File.dirname(__FILE__) + '/test_helper'

class WireFormatDecoderTest < Test::Unit::TestCase

  context "a message with one int32 field tagged #1" do
    # from http://code.google.com/apis/protocolbuffers/docs/encoding.html#simple
    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_decode_wire_format_to_fields [0x08, 0x96, 0x01], :a => 150

    # should ignore unknown fields: this message also has an int32 tagged #2 with value 157,372
    should_decode_wire_format_to_fields [0x08, 0x96, 0x01, 0x10, 0xBC, 0xCD, 0x09], :a => 150
  end

end