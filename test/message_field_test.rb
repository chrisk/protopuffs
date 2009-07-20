# encoding: UTF-8

require File.dirname(__FILE__) + '/test_helper'

class MessageFieldTest < Test::Unit::TestCase

  context "creating a MessageField" do
    should "not allow you to instantiate MessageField directly" do
      assert_raises RuntimeError do
        Protopuffs::MessageField.new "_", "_", "_", "_"
      end
    end

    should "complain if an invalid modifier is specified" do
      ["optional", "required", "repeated"].each do |modifier|
        assert_nothing_raised {Protopuffs::Int32.new(modifier, 'identitifer', 1)}
      end
      assert_raises(ArgumentError) {Protopuffs::Int32.new("invalid_modifier", "identifier", 1)}
    end

    should "instantiate the right class, given a type string" do
      [[ "int32",    Protopuffs::Int32],
       [ "int64",    Protopuffs::Int64],
       [ "uint32",   Protopuffs::UInt32],
       [ "uint64",   Protopuffs::UInt64],
       [ "bool",     Protopuffs::Bool],
       [ "double",   Protopuffs::Double],
       [ "fixed64",  Protopuffs::Fixed64],
       [ "string",   Protopuffs::String],
       [ "bytes",    Protopuffs::Bytes],
       [ "float",    Protopuffs::Float],
       [ "fixed32",  Protopuffs::Fixed32],
       [ "sfixed32", Protopuffs::SFixed32],
       [ "embedded", Protopuffs::Embedded],
      ].each do |type, klass|
        assert_kind_of klass, Protopuffs::MessageField.factory(type, "optional", "a_string", 1, 2)
      end
    end

    should "set a string's default to '' when a default isn't specified" do
      field = Protopuffs::String.new("optional", "name", 1)
      assert_equal "", field.default
    end

    should "set a string's default to '' when a default is specified as nil" do
      field = Protopuffs::String.new("optional", "name", 1, nil)
      assert_equal "", field.default
    end

    should "set a numeric's default to 0 when a default isn't specified or is specified as nil" do
      numeric_types = [Protopuffs::Double, Protopuffs::Float,
                       Protopuffs::Int32, Protopuffs::Int64,
                       Protopuffs::UInt32, Protopuffs::UInt64,
                       Protopuffs::Fixed32, Protopuffs::Fixed64,
                       Protopuffs::SFixed32]
      numeric_types.each do |type|
        assert_equal 0, type.new("optional", "number", 1).default
        assert_equal 0, type.new("optional", "number", 1, nil).default
      end
    end

    should "set a bool's default to false when a default isn't specified" do
      field = Protopuffs::Bool.new("optional", "opt_in", 1)
      assert_same false, field.default
    end

    should "set a bool's default to false when a default is specified as nil" do
      field = Protopuffs::Bool.new("optional", "opt_in", 1, nil)
      assert_same false, field.default
    end

    should "set the default to 'Matz' when that default is specified" do
      field = Protopuffs::String.new("optional", "name", 1, "Matz")
      assert_equal "Matz", field.default
    end
  end

end
