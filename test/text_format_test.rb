# encoding: UTF-8

require File.dirname(__FILE__) + '/test_helper'

class TextFormatTest < Test::Unit::TestCase

  context "a message called Test1 with one int32 field" do
    # from http://code.google.com/apis/protocolbuffers/docs/overview.html#whynotxml
    setup do
      fields = [Protopuffs::String.new("required", "name", 1),
                Protopuffs::String.new("required", "email", 2)]
      Protopuffs::Message::Base.define_message_class("Person", fields)
      @message = Protopuffs::Message::Person.new
      @message.name = "John Doe"
      @message.email = "jdoe@example.com"
    end

    should "return the correct text format from #inspect" do
      assert_equal %Q(person {\n  name: "John Doe"\n  email: "jdoe@example.com"\n}), @message.inspect
    end
  end

end
