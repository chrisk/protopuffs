require File.dirname(__FILE__) + '/test_helper'

class ProtopuffsTest < Test::Unit::TestCase

  context ".proto_load_path" do
    should "be an accessor for an array of load paths for .proto files" do
      Protopuffs.proto_load_path << "proto_files" << "other_proto_files"
      assert_equal ["proto_files", "other_proto_files"], Protopuffs.proto_load_path
    end
  end

end