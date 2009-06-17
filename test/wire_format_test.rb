require File.dirname(__FILE__) + '/test_helper'

class WireFormatTest < Test::Unit::TestCase

  context "a message with one int32 field tagged #1" do
    # from http://code.google.com/apis/protocolbuffers/docs/encoding.html#simple
    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x08, 0x96, 0x01], :a => 150
    should_decode_wire_format_to_fields   [0x08, 0x96, 0x01], :a => 150

    # should ignore unknown fields: this message also has an int32 tagged #2 with value 157,372
    should_decode_wire_format_to_fields [0x08, 0x96, 0x01, 0x10, 0xBC, 0xCD, 0x09], :a => 150

    should "return itself from #from_wire_format" do
      wire_message = StringIO.new([0x08, 0x96, 0x01].pack('C*'))
      assert_same @message, @message.from_wire_format(wire_message)
    end

    should "accept a string as an argument to #from_wire_format" do
      wire_message = [0x08, 0x96, 0x01].pack('C*')
      @message.from_wire_format(wire_message)
      assert_equal 150, @message.a
    end
  end


  context "a message with two int32 fields tagged #1 and #2" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1),
                Protopuffs::MessageField.new("required", "int32", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x08, 0x96, 0x01, 0x10, 0xBC, 0xCD, 0x09],
                                          :a => 150, :b => 157_372
    should_decode_wire_format_to_fields   [0x08, 0x96, 0x01, 0x10, 0xBC, 0xCD, 0x09],
                                          :a => 150, :b => 157_372
  end


  context "a message with one int64 field tagged #1" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "int64", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x08, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x02],
                                          :a => 2**50
    should_decode_wire_format_to_fields   [0x08, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x02],
                                          :a => 2**50
  end


  context "a message with one uint32 field tagged #1 and one uint64 field tagged #2" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "uint32", "a", 1),
                Protopuffs::MessageField.new("required", "uint64", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x08, 0x90, 0x07, 0x10, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x20],
                                          :a => 912, :b => 2**54
    should_decode_wire_format_to_fields   [0x08, 0x90, 0x07, 0x10, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x20],
                                          :a => 912, :b => 2**54
  end


  context "a message with two bool fields tagged #1 and #2" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "bool", "a", 1),
                Protopuffs::MessageField.new("required", "bool", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x08, 0x00, 0x10, 0x01],
                                          :a => false, :b => true
    should_decode_wire_format_to_fields   [0x08, 0x00, 0x10, 0x01],
                                          :a => false, :b => true
  end


  context "a message with one string field tagged #2" do
    setup do
      # from http://code.google.com/apis/protocolbuffers/docs/encoding.html#types
      fields = [Protopuffs::MessageField.new("required", "string", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test2", fields)
      @message = Protopuffs::Message::Test2.new
    end

    should_encode_wire_format_from_fields [0x12, 0x07, 0x74, 0x65, 0x73, 0x74, 0x69, 0x6E, 0x67],
                                          :b => "testing"
    should_decode_wire_format_to_fields   [0x12, 0x07, 0x74, 0x65, 0x73, 0x74, 0x69, 0x6E, 0x67],
                                          :b => "testing"
  end


  context "a message with a bytes field tagged #1" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "bytes", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x0A, 0x04, 0xDE, 0xCA, 0xFB, 0xAD],
                                          :a => [0xDE, 0xCA, 0xFB, 0xAD].pack('C*')
    should_decode_wire_format_to_fields   [0x0A, 0x04, 0xDE, 0xCA, 0xFB, 0xAD],
                                          :a => [0xDE, 0xCA, 0xFB, 0xAD].pack('C*')
  end


  context "a message with one float field tagged #1" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "float", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    # 1.61803 gives you repeating binary digits when encoded, so the number
    # you get from decoding is different (within Float::EPSILON)
    should_encode_wire_format_from_fields [0x0D, 0x9B, 0x1B, 0xCF, 0x3F],
                                          :a => 1.61803
    should_decode_wire_format_to_fields   [0x0D, 0x9B, 0x1B, 0xCF, 0x3F],
                                          :a => 1.6180299520492554
  end


  context "a message with one double field tagged #1" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "double", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    # 64-bit doubles have enough precision to encode/decode 1.61803,
    # unlike the 32-bit floats above
    should_encode_wire_format_from_fields [0x09, 0x6C, 0x26, 0xDF, 0x6C, 0x73, 0xE3, 0xF9, 0x3F],
                                          :a => 1.61803
    should_decode_wire_format_to_fields   [0x09, 0x6C, 0x26, 0xDF, 0x6C, 0x73, 0xE3, 0xF9, 0x3F],
                                          :a => 1.61803
  end


  context "a message with one fixed64 field tagged #1" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "fixed64", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x09, 0xF1, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3F],
                                          :a => 2**62 - 15
    should_decode_wire_format_to_fields   [0x09, 0xF1, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3F],
                                          :a => 2**62 - 15

  end


  context "a message with one fixed32 field tagged #1" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "fixed32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x0D, 0xFE, 0xFF, 0xFF, 0xFF],
                                          :a => 2**32 - 2
    should_decode_wire_format_to_fields   [0x0D, 0xFE, 0xFF, 0xFF, 0xFF],
                                          :a => 2**32 - 2
  end


  context "a message with one repeating int32 field tagged #1" do
    setup do
      fields = [Protopuffs::MessageField.new("repeated", "int32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x08, 0x96, 0x01, 0x08, 0xBC, 0xCD, 0x09, 0x08, 0x3D],
                                          :a => [150, 157_372, 61]
    should_decode_wire_format_to_fields   [0x08, 0x96, 0x01, 0x08, 0xBC, 0xCD, 0x09, 0x08, 0x3D],
                                          :a => [150, 157_372, 61]
  end


  context "a message with one embedded-message field Test1 tagged #3 (where Test1 has an int32 field tagged #1)" do
    # from http://code.google.com/apis/protocolbuffers/docs/encoding.html#embedded
    setup do
      test1_fields = [Protopuffs::MessageField.new("required", "int32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", test1_fields)

      test3_fields = [Protopuffs::MessageField.new("required", "Test1", "c", 3)]
      Protopuffs::Message::Base.define_message_class("Test3", test3_fields)
      @message = Protopuffs::Message::Test3.new
    end

    should_encode_wire_format_from_fields [0x1A, 0x03, 0x08, 0x96, 0x01],
                                          :c => lambda { msg = Protopuffs::Message::Test1.new; msg.a = 150; msg }
    should_decode_wire_format_to_fields   [0x1A, 0x03, 0x08, 0x96, 0x01],
                                          :c => lambda { msg = Protopuffs::Message::Test1.new; msg.a = 150; msg }
  end


  context "a message with two int32 fields tagged #1 (optional, default=150) and #2 (required)" do
    setup do
      fields = [Protopuffs::MessageField.new("optional", "int32", "a", 1, 150),
                Protopuffs::MessageField.new("required", "int32", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x10, 0xBC, 0xCD, 0x09],
                                          :b => 157_372
    should_decode_wire_format_to_fields   [0x10, 0xBC, 0xCD, 0x09],
                                          :a => 150, :b => 157_372
  end


  context "a message with two int32 fields tagged #1 (optional, no default) and #2 (required)" do
    setup do
      fields = [Protopuffs::MessageField.new("optional", "int32", "a", 1),
                Protopuffs::MessageField.new("required", "int32", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x10, 0xBC, 0xCD, 0x09],
                                          :b => 157_372
    should_decode_wire_format_to_fields   [0x10, 0xBC, 0xCD, 0x09],
                                          :a => 0, :b => 157_372
  end

  context "string fields should convert their values to strings" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "string", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
    end

    should_encode_wire_format_from_fields [0x0A, 0x04, 0x32],
                                          :a => 2
  end

end
