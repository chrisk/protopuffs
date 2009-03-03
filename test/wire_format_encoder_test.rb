require File.dirname(__FILE__) + '/test_helper'

class WireFormatEncoderTest < Test::Unit::TestCase

  context "a message with one int32 field set to 150" do
    # from http://code.google.com/apis/protocolbuffers/docs/encoding.html#simple
    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 150
    end

    should_serialize_to_wire_format 0x08, 0x96, 0x01
  end


  context "a message with two int32 fields set to 150 and 157,372, respectively" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1),
                Protopuffs::MessageField.new("required", "int32", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 150
      @message.b = 157_372
    end

    should_serialize_to_wire_format 0x08, 0x96, 0x01, 0x10, 0xBC, 0xCD, 0x09
  end


  context "a message with one int64 field set to 2^50" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "int64", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 2**50
    end

    should_serialize_to_wire_format 0x08, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x02
  end


  context "a message with one uint32 field set to 912 and one uint64 field set to 2^54" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "uint32", "a", 1),
                Protopuffs::MessageField.new("required", "uint64", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 912
      @message.b = 2**54
    end

    should_serialize_to_wire_format 0x08, 0x90, 0x07, 0x10, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x20
  end


  context "a message with two bool fields set to false and true, respectively" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "bool", "a", 1),
                Protopuffs::MessageField.new("required", "bool", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = false
      @message.b = true
    end

    should_serialize_to_wire_format 0x08, 0x00, 0x10, 0x01
  end


  context "a message with one string field set to 'testing'" do
    setup do
      # from http://code.google.com/apis/protocolbuffers/docs/encoding.html#types
      fields = [Protopuffs::MessageField.new("required", "string", "b", 2)]
      Protopuffs::Message::Base.define_message_class("Test2", fields)
      @message = Protopuffs::Message::Test2.new
      @message.b = "testing"
    end

    should_serialize_to_wire_format 0x12, 0x07, 0x74, 0x65, 0x73, 0x74, 0x69, 0x6E, 0x67
  end


  context "a message with a bytes field set to [DE CA FB AD]" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "bytes", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = [0xDE, 0xCA, 0xFB, 0xAD].pack('C*')
    end

    should_serialize_to_wire_format 0x0A, 0x04, 0xDE, 0xCA, 0xFB, 0xAD
  end


  context "a message with one float field set to 1.61803" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "float", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 1.61803
    end

    should_serialize_to_wire_format 0x0D, 0x9B, 0x1B, 0xCF, 0x3F
  end


  context "a message with one double field set to 1.61803" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "double", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 1.61803
    end

    should_serialize_to_wire_format 0x09, 0x6C, 0x26, 0xDF, 0x6C, 0x73, 0xE3, 0xF9, 0x3F
  end


  context "a message with one fixed64 field set to 2^62-15" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "fixed64", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 2**62 - 15
    end

    should_serialize_to_wire_format 0x09, 0xF1, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3F
  end


  context "a message with one fixed32 field set to 2^32-2" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "fixed32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 2**32 - 2
    end

    should_serialize_to_wire_format 0x0D, 0xFE, 0xFF, 0xFF, 0xFF
  end


  context "a message with one repeating int32 field set to 150, 157,372, and 61" do
    setup do
      fields = [Protopuffs::MessageField.new("repeated", "int32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = [150, 157_372, 61]
    end

    should_serialize_to_wire_format 0x08, 0x96, 0x01, 0x08, 0xBC, 0xCD, 0x09, 0x08, 0x3D
  end


  context "a message with one embedded-message field Test1 (which has an int32 set to 150)" do
    # from http://code.google.com/apis/protocolbuffers/docs/encoding.html#embedded
    setup do
      test1_fields = [Protopuffs::MessageField.new("required", "int32", "a", 1)]
      Protopuffs::Message::Base.define_message_class("Test1", test1_fields)
      @embedded_message = Protopuffs::Message::Test1.new
      @embedded_message.a = 150

      test3_fields = [Protopuffs::MessageField.new("required", "Test1", "c", 3)]
      Protopuffs::Message::Base.define_message_class("Test3", test3_fields)
      @message = Protopuffs::Message::Test3.new
      @message.c = @embedded_message
    end

    should_serialize_to_wire_format 0x1A, 0x03, 0x08, 0x96, 0x01
  end

end