require File.dirname(__FILE__) + '/test_helper'

class MessageBaseTest < Test::Unit::TestCase

  context ".define_message_class using 'Person' and two fields" do
    should "create a Message::Person class" do
      fields = [Protopuffs::String.new("optional", "name", 1),
                Protopuffs::String.new("optional", "address", 2)]
      Protopuffs::Message::Base.define_message_class("Person", fields)
      Protopuffs::Message::Person
    end

    should "create a class with accessors for each field" do
      fields = [Protopuffs::String.new("optional", "name", 1),
                Protopuffs::String.new("optional", "address", 2)]
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
      fields = [Protopuffs::Int32.new("optional", "name", 1),
                Protopuffs::String.new("optional", "address", 1)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message::Base.define_message_class("Person", fields)
      end
    end
  end


  context ".define_message_class with fields that have invalid tags" do
    should "raise a Protopuffs::ParseError when a tag is too large" do
      fields = [Protopuffs::Int32.new("optional", "name", 1),
                Protopuffs::String.new("optional", "address", 536_870_912)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message::Base.define_message_class("Person", fields)
      end
    end

    should "raise a Protopuffs::ParseError when a tag is too small" do
      fields = [Protopuffs::Int32.new("optional", "name", 0),
                Protopuffs::String.new("optional", "address", 1)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message::Base.define_message_class("Person", fields)
      end
    end

    should "raise a Protopuffs::ParseError when a tag is reserved" do
      fields = [Protopuffs::String.new("optional", "name", 19050)]
      assert_raises Protopuffs::ParseError do
        Protopuffs::Message::Base.define_message_class("Person", fields)
      end
    end
  end


  context ".define_message_class with a message name that's Camel_Scored" do
    # violates the Google style guide, but the other implementations handle this
    should "strip the underscore when creating the class" do
      Protopuffs::Message::Base.define_message_class("User_Image", [])
      assert !Protopuffs::Message.const_defined?("User_Image")
      assert Protopuffs::Message.const_defined?("UserImage")
    end

    context "and an embedded-message field that's Camel_Scored" do
      should "strip the underscore when instantiating the class of the field" do
        child_fields = [Protopuffs::String.new("optional", "street", 1)]
        Protopuffs::Message::Base.define_message_class("User_Address", child_fields)
        parent_fields = [Protopuffs::Embedded.new("User_Address", "required", "user_address", 1)]
        Protopuffs::Message::Base.define_message_class("User_Info", parent_fields)

        child = Protopuffs::Message::UserAddress.new(:street => "400 2nd Street")
        parent = Protopuffs::Message::UserInfo.new(child.to_wire_format)

        assert_equal Protopuffs::Message::UserAddress, parent.user_address.class
      end
    end
  end


  should "not allow you to instantiate Message::Base directly" do
    assert_raises RuntimeError do
      Protopuffs::Message::Base.new
    end
  end


  context "comparing messages with #==" do
    should "return false when the messages have different types" do
      Protopuffs::Message::Base.define_message_class("Dog", [])
      Protopuffs::Message::Base.define_message_class("Cat", [])
      assert_not_equal Protopuffs::Message::Dog.new, Protopuffs::Message::Cat.new
    end

    should "return false when the messages' fields have different values" do
      fields = [Protopuffs::String.new("optional", "name", 1)]
      Protopuffs::Message::Base.define_message_class("Person", fields)
      alice = Protopuffs::Message::Person.new
      alice.name = "Alice"
      bob = Protopuffs::Message::Person.new
      bob.name = "Bob"
      assert_not_equal alice, bob
    end

    should "return true when messages of the same type have the same field values" do
      fields = [Protopuffs::String.new("optional", "name", 1)]
      Protopuffs::Message::Base.define_message_class("Sheep", fields)
      sheep = Protopuffs::Message::Sheep.new
      sheep.name = "Dolly"
      sheep2 = Protopuffs::Message::Sheep.new
      sheep2.name = "Dolly"
      assert_equal sheep, sheep2
    end
  end


  context "instantiating a message class" do
    setup do
      fields = [Protopuffs::String.new("required", "title", 2)]
      Protopuffs::Message::Base.define_message_class("Book", fields)
    end

    should "optionally accept a wire-format encoded IO-style object and populate the fields" do
      input = StringIO.new([0x12, 0x07, 0x74, 0x65, 0x73, 0x74, 0x69, 0x6E, 0x67].pack("C*"))
      message = Protopuffs::Message::Book.new(input)
      assert_equal "testing", message.title
    end

    should "optionally accept a wire-format encoded string and populate the fields" do
      input = [0x12, 0x07, 0x74, 0x65, 0x73, 0x74, 0x69, 0x6E, 0x67].pack("C*")
      message = Protopuffs::Message::Book.new(input)
      assert_equal "testing", message.title
    end

    should "not populate the fields if no argument is present" do
      message = Protopuffs::Message::Book.new
      assert_nil message.title
    end

    should "optionally accept a hash of field values and mass-assign them" do
      message = Protopuffs::Message::Book.new(:title => "testing")
      assert_equal "testing", message.title
    end
  end


  context "mass-assignment of field values via #attributes=" do
    setup do
      fields = [Protopuffs::String.new("required", "title", 1),
                Protopuffs::String.new("required", "author", 2),
                Protopuffs::Int32.new("optional", "edition", 3)]
      Protopuffs::Message::Base.define_message_class("Book", fields)
    end

    should "set each field value to the corresponding entry in the argument hash" do
      message = Protopuffs::Message::Book.new
      message.attributes = {:title   => "You Shall Know Our Velocity",
                            :author  => "Dave Eggers",
                            :edition => 2}
      assert_equal "You Shall Know Our Velocity", message.title
      assert_equal "Dave Eggers", message.author
      assert_equal 2, message.edition
    end

    should "ignore unknown fields in the argument hash" do
      message = Protopuffs::Message::Book.new
      message.attributes = {:title   => "You Shall Know Our Velocity",
                            :author  => "Dave Eggers",
                            :edition => 2,
                            :isbn    => "0970335555"}
      assert_equal "You Shall Know Our Velocity", message.title
      assert_equal "Dave Eggers", message.author
      assert_equal 2, message.edition
    end

    should "only assign fields present in the argument hash" do
      message = Protopuffs::Message::Book.new
      message.title = "You Shall Know Our Velocity"
      message.attributes = {:author => "Dave Eggers"}
      assert_equal "Dave Eggers", message.author
      assert_equal "You Shall Know Our Velocity", message.title
      assert_nil message.edition
    end

    should "not assign defaults for optional fields missing from the argument hash" do
      message = Protopuffs::Message::Book.new
      message.attributes = {:author => "Dave Eggers"}
      assert_equal "Dave Eggers", message.author
      assert_nil message.title
      assert_nil message.edition
    end
  end

end
