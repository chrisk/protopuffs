require File.dirname(__FILE__) + '/test_helper'

class MessageTest < Test::Unit::TestCase

  context "when a MessageDescriptor for 'Person' is created" do
    should "create a Message::Person class" do
      fields = [Protopuffs::MessageField.new("optional", "string", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 2)]
      Protopuffs::MessageDescriptor.new("Person", fields)
      assert_equal Protopuffs::Message::Person.new.to_wire_format, "12"
    end

    should "create a Message::Person class with accessors for each field" do
      fields = [Protopuffs::MessageField.new("optional", "string", "name", 1),
                Protopuffs::MessageField.new("optional", "string", "address", 2)]
      Protopuffs::MessageDescriptor.new("Person", fields)
      person = Protopuffs::Message::Person.new
      person.name = "Chris"
      person.address = "61 Carmelita St."
      assert_equal person.name, "Chris"
      assert_equal person.address, "61 Carmelita St."
    end

  end

end