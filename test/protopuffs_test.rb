require File.dirname(__FILE__) + '/test_helper'

class ProtopuffsTest < Test::Unit::TestCase

  context ".proto_load_path accessors" do
    setup { Protopuffs.proto_load_path = [] }

    should "have an accessor for an array of load paths for .proto files" do
      Protopuffs.proto_load_path << "proto_files" << "other_proto_files"
      assert_equal ["proto_files", "other_proto_files"], Protopuffs.proto_load_path
    end

    should "have a mutator for directly assigning the load paths" do
      Protopuffs.proto_load_path = ["my_proto_files"]
      assert_equal ["my_proto_files"], Protopuffs.proto_load_path
    end
  end

  should "have a ParseError class" do
    Protopuffs::ParseError
  end


  context ".load_message_classes when a descriptor is in the load path with a Person message" do
    setup { Protopuffs.proto_load_path = ["#{File.dirname(__FILE__)}/fixtures/proto"] }

    should "create a Person message class with correct accessors" do
      Protopuffs.load_message_classes
      p = Protopuffs::Message::Person.new
      p.name = "Chris"
      p.id = 42
      p.email = "chris@kampers.net"
      assert_equal ["Chris", 42, "chris@kampers.net"], [p.name, p.id, p.email]
    end
  end
end