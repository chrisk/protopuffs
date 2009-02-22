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

  context "conversion to wire types" do
    should "return 0 for int32" do
      field = Protopuffs::MessageField.new("required", "int32", "age", 1)
      assert_equal 0, field.wire_type
    end

    should "return 0 for int64" do
      field = Protopuffs::MessageField.new("required", "int64", "age", 1)
      assert_equal 0, field.wire_type
    end

    should "return 0 for uint32" do
      field = Protopuffs::MessageField.new("required", "uint32", "age", 1)
      assert_equal 0, field.wire_type
    end

    should "return 0 for uint64" do
      field = Protopuffs::MessageField.new("required", "uint64", "age", 1)
      assert_equal 0, field.wire_type
    end

    should "return 0 for bool" do
      field = Protopuffs::MessageField.new("required", "bool", "enabled", 1)
      assert_equal 0, field.wire_type
    end

    should "return 2 for string" do
      field = Protopuffs::MessageField.new("required", "string", "name", 1)
      assert_equal 2, field.wire_type
    end

    should "return 2 for bytes" do
      field = Protopuffs::MessageField.new("required", "bytes", "data", 1)
      assert_equal 2, field.wire_type
    end

    should "return 5 for float" do
      field = Protopuffs::MessageField.new("required", "float", "ratio", 1)
      assert_equal 5, field.wire_type
    end

    should "return 1 for double" do
      field = Protopuffs::MessageField.new("required", "double", "ratio", 1)
      assert_equal 1, field.wire_type
    end

    should "return 1 for fixed64" do
      field = Protopuffs::MessageField.new("required", "fixed64", "bigcount", 1)
      assert_equal 1, field.wire_type
    end

    should "return 5 for fixed32" do
      field = Protopuffs::MessageField.new("required", "fixed32", "count", 1)
      assert_equal 5, field.wire_type
    end
  end
end