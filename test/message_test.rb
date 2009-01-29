require File.dirname(__FILE__) + '/test_helper'

class MessageTest < Test::Unit::TestCase

  context "creating a Message with fields that have duplicate tags" do
    should "raise a Protopuffs::ParseError" do
      fields = [Protopuffs::MessageField.new("optional", "int32", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 1)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message.new("Person", fields)
      end
    end
  end

end