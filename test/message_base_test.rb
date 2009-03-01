require File.dirname(__FILE__) + '/test_helper'

class MessageBaseTest < Test::Unit::TestCase

  context ".define_message_class using 'Person' and two fields" do
    should "create a Message::Person class" do
      fields = [Protopuffs::MessageField.new("optional", "string", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 2)]
      Protopuffs::Message::Base.define_message_class("Person", fields)
      Protopuffs::Message::Person
    end

    should "create a class with accessors for each field" do
      fields = [Protopuffs::MessageField.new("optional", "string", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 2)]
      Protopuffs::Message::Base.define_message_class("Person", fields)
      person = Protopuffs::Message::Person.new
      person.name = "Chris"
      person.address = "61 Carmelita St."
      assert_equal person.name, "Chris"
      assert_equal person.address, "61 Carmelita St."
    end
  end


  context ".define_message_class with fields that have duplicate tags" do
    should "raise a Protopuffs::ParseError" do
      fields = [Protopuffs::MessageField.new("optional", "int32", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 1)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message::Base.define_message_class("Person", fields)
      end
    end
  end


  context ".define_message_class with fields that have invalid tags" do
    should "raise a Protopuffs::ParseError when a tag is too large" do
      fields = [Protopuffs::MessageField.new("optional", "int32", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 536_870_912)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message::Base.define_message_class("Person", fields)
      end
    end

    should "raise a Protopuffs::ParseError when a tag is too small" do
      fields = [Protopuffs::MessageField.new("optional", "int32", "name", 0),
                Protopuffs::MessageField.new("optional", "string", "address", 1)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message::Base.define_message_class("Person", fields)
      end
    end

    should "raise a Protopuffs::ParseError when a tag is reserved" do
      fields = [Protopuffs::MessageField.new("optional", "string", "name", 19050)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message::Base.define_message_class("Person", fields)
      end
    end
  end


  should "not allow you to instantiate Message::Base directly" do
    assert_raises RuntimeError do
      Protopuffs::Message::Base.new
    end
  end

end