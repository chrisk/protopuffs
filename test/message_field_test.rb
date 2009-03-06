require File.dirname(__FILE__) + '/test_helper'

class MessageFieldTest < Test::Unit::TestCase

  context "creating a MessageField" do
    should "set a string's default to '' when a default isn't specified" do
      field = Protopuffs::MessageField.new("optional", "string", "name", 1)
      assert_equal "", field.default
    end

    should "set a numeric's default to 0 when a default isn't specified" do
      numeric_types = %w(double float int32 int64 uint32 unit64 sint32 sint64
                         fixed32 fixed64 sfixed32 sfixed64)
      numeric_types.each do |type|
        assert_equal 0, Protopuffs::MessageField.new("optional", type, "number", 1).default
      end
    end

    should "set a bool's default to false when a default isn't specified" do
      field = Protopuffs::MessageField.new("optional", "bool", "opt_in", 1)
      assert_same false, field.default
    end

    should "set the default to 'Matz' when that default is specified" do
      field = Protopuffs::MessageField.new("optional", "string", "name", 1, "Matz")
      assert_equal "Matz", field.default
    end
  end

  should_return_wire_type_for_fields_typed 0 => %w(int32 int64 uint32 uint64 bool),
                                           1 => %w(double fixed64),
                                           2 => %w(bytes string TestMessage),
                                           5 => %w(float fixed32)
end