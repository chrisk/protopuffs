require File.dirname(__FILE__) + '/test_helper'

class AbstractSyntaxTreeTest < Test::Unit::TestCase

  context "a protocol buffer descriptor" do
    setup do
      @parser = Protopuffs::Parser::ProtocolBufferDescriptor.new
    end

    context "with an empty Person message" do
      setup do
        @descriptor = "message Person {}"
      end

      should "create one Message" do
        Protopuffs::Message.expects(:new).once.with("Person", [])
        @parser.parse(@descriptor)
      end

      should "not create any MessageFields" do
        Protopuffs::MessageField.expects(:new).never
        @parser.parse(@descriptor)
      end
    end


    context "with two empty messages Apple and Orange" do
      setup do
        @descriptor = <<-proto
          message Apple {}
          message Orange {}
        proto
      end

      should "create two Messages" do
        Protopuffs::Message.expects(:new).once.with("Apple", []).in_sequence
        Protopuffs::Message.expects(:new).once.with("Orange", []).in_sequence
        @parser.parse(@descriptor)
      end

      should "not create any MessageFields" do
        Protopuffs::MessageField.expects(:new).never
        @parser.parse(@descriptor)
      end
    end


    context "a proto with a Person message including a name field" do
      setup do
        @descriptor = <<-proto
          message Person {
            required string name = 1;
          }
        proto
      end

      should "create one 'Person' Message with one field" do
        Protopuffs::Message.expects(:new).once.with("Person", responds_with(:size, 1))
        @parser.parse(@descriptor)
      end

      should "create one MessageField with correct options" do
        Protopuffs::MessageField.expects(:new).once.with("required", "string", "name", 1, nil)
        @parser.parse(@descriptor)
      end
    end


    context "with a Person message including three fields" do
      setup do
        @descriptor = <<-proto
          message Person {
            required string name = 1;
            required int32 id = 2;
            optional string email = 3;
          }
        proto
      end

      should "create one 'Person' Message with three fields" do
        Protopuffs::Message.expects(:new).once.with("Person", responds_with(:size, 3))
        @parser.parse(@descriptor)
      end

      should "create three MessageFields with correct options" do
        Protopuffs::MessageField.expects(:new).once.with("required", "string", "name", 1, nil).in_sequence
        Protopuffs::MessageField.expects(:new).once.with("required", "int32", "id", 2, nil).in_sequence
        Protopuffs::MessageField.expects(:new).once.with("optional", "string", "email", 3, nil).in_sequence
        @parser.parse(@descriptor)
      end
    end


    context "with a message including two fields with defaults and one without" do
      setup do
        @descriptor = <<-proto
          message Person {
            required string name = 1;
            optional string language = 2 [default = "en"];
            optional int32 account_code = 3 [default = 0];
          }
        proto
      end

      should "create one 'Person' Message with three fields" do
        Protopuffs::Message.expects(:new).once.with("Person", responds_with(:size, 3))
        @parser.parse(@descriptor)
      end

      should "create three MessageFields with correct options" do
        Protopuffs::MessageField.expects(:new).once.with("required", "string", "name", 1, nil).in_sequence
        Protopuffs::MessageField.expects(:new).once.with("optional", "string", "language", 2, "en").in_sequence
        Protopuffs::MessageField.expects(:new).once.with("optional", "int32", "account_code", 3, 0).in_sequence
        @parser.parse(@descriptor)
      end
    end


    context "with a message including a user-typed field" do
      setup do
        @descriptor = <<-proto
          message Person {
            required string name = 1;
            repeated Address addresses = 2;
          }
        proto
      end

      should "create one 'Person' Message with two fields" do
        Protopuffs::Message.expects(:new).once.with("Person", responds_with(:size, 2))
        @parser.parse(@descriptor)
      end

      should "create two MessageFields  with correct options" do
        Protopuffs::MessageField.expects(:new).once.with("required", "string", "name", 1, nil).in_sequence
        Protopuffs::MessageField.expects(:new).once.with("repeated", "Address", "addresses", 2, nil).in_sequence
        @parser.parse(@descriptor)
      end
    end
  end

end