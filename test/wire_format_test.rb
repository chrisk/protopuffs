require File.dirname(__FILE__) + '/test_helper'

class WireFormatTest < Test::Unit::TestCase

  context "a message with one int32 field set to 150" do
    # from http://code.google.com/apis/protocolbuffers/docs/encoding.html#simple
    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1)]
      Protopuffs::MessageDescriptor.new("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 150
    end

    should_serialize_to_wire_format 0x08, 0x96, 0x01
  end


  context "a message with two int32 fields set to 150 and 157,372, respectively" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1),
                Protopuffs::MessageField.new("required", "int32", "b", 2)]
      Protopuffs::MessageDescriptor.new("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 150
      @message.b = 157_372
    end

    should_serialize_to_wire_format 0x08, 0x96, 0x01, 0x10, 0xBC, 0xCD, 0x09
  end


  context "a message with one int64 field set to 2^50" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "int64", "a", 1)]
      Protopuffs::MessageDescriptor.new("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      @message.a = 2**50
    end

    should_serialize_to_wire_format 0x08, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x02
  end


  context "a message with one uint32 field set to 912 and one uint64 field set to 2^54" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "uint32", "a", 1),
                Protopuffs::MessageField.new("required", "uint64", "b", 2)]
      Protopuffs::MessageDescriptor.new("Test1", fields)
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
      Protopuffs::MessageDescriptor.new("Test1", fields)
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
      Protopuffs::MessageDescriptor.new("Test2", fields)
      @message = Protopuffs::Message::Test2.new
      @message.b = "testing"
    end

    should_serialize_to_wire_format 0x12, 0x07, 0x74, 0x65, 0x73, 0x74, 0x69, 0x6E, 0x67
  end


  context "a message with one bytes field set to [0xDE 0xAD 0xBE 0xEF]" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "bytes", "a", 1)]
      Protopuffs::MessageDescriptor.new("Test1", fields)
      @message = Protopuffs::Message::Test1.new
      bytes = "...."
      bytes[0] = 0xDE; bytes[1] = 0xAD; bytes[2] = 0xBE; bytes[3] = 0xEF
      @message.a = bytes
    end

    should_serialize_to_wire_format 0x0A, 0x04, 0xDE, 0xAD, 0xBE, 0xEF
  end
end