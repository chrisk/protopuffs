require File.dirname(__FILE__) + '/test_helper'

class WireFormatTest < Test::Unit::TestCase

  context "a MessageDescriptor with one int32 field" do
    # from http://code.google.com/apis/protocolbuffers/docs/encoding.html

    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1)]
      Protopuffs::MessageDescriptor.new("Test1", fields)
      @test1 = Protopuffs::Message::Test1.new
    end

    should "serialize the message correctly when the field is set to 150" do
      @test1.a = 150
      output = @test1.to_wire_format
      assert_equal 0x08, output[0]
      assert_equal 0x96, output[1]
      assert_equal 0x01, output[2]
    end
  end

  context "a MessageDescriptor with two int32 fields" do
    setup do
      fields = [Protopuffs::MessageField.new("required", "int32", "a", 1),
                Protopuffs::MessageField.new("required", "int32", "b", 2)]
      Protopuffs::MessageDescriptor.new("Test1", fields)
      @test1 = Protopuffs::Message::Test1.new
    end

    should "serialize the message correctly when the fields are set to 150 and 157,372" do
      @test1.a = 150
      @test1.b = 157_372
      output = @test1.to_wire_format
      assert_equal 0x08, output[0]
      assert_equal 0x96, output[1]
      assert_equal 0x01, output[2]
      assert_equal 0x10, output[3]
      assert_equal 0xBC, output[4]
      assert_equal 0xCD, output[5]
      assert_equal 0x09, output[6]
    end
  end

end