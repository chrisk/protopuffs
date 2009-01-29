require File.dirname(__FILE__) + '/test_helper'

class MessageFieldTest < Test::Unit::TestCase

  context "creating a MessageField" do
    should "set the default to nil when a default isn't specified" do
      field = Protopuffs::MessageField.new("optional", "string", "name", 1)
      assert_nil field.default
    end

    should "set the default to 'Matz' when that default is specified" do
      field = Protopuffs::MessageField.new("optional", "string", "name", 1, "Matz")
      assert_equal "Matz", field.default
    end
  end

end