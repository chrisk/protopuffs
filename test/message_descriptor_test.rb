require File.dirname(__FILE__) + '/test_helper'

class MessageDescriptorTest < Test::Unit::TestCase

  context "creating a MessageDescriptor with fields that have duplicate tags" do
    should "raise a Protopuffs::ParseError" do
      fields = [Protopuffs::MessageField.new("optional", "int32", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 1)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::MessageDescriptor.new("Person", fields)
      end
    end
  end


  context "creating a MessageDescriptor with fields that have invalid tags" do
    should "raise a Protopuffs::ParseError when a tag is too large" do
      fields = [Protopuffs::MessageField.new("optional", "int32", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 536_870_912)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::MessageDescriptor.new("Person", fields)
      end
    end

    should "raise a Protopuffs::ParseError when a tag is too small" do
      fields = [Protopuffs::MessageField.new("optional", "int32", "name", 0),
                Protopuffs::MessageField.new("optional", "string", "address", 1)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::MessageDescriptor.new("Person", fields)
      end
    end

    should "raise a Protopuffs::ParseError when a tag is reserved" do
      fields = [Protopuffs::MessageField.new("optional", "string", "name", 19050)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::MessageDescriptor.new("Person", fields)
      end
    end
  end

end