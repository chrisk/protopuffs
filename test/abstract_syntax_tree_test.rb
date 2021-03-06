# encoding: UTF-8

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

      should "create one message class" do
        Protopuffs::Message::Base.expects(:define_message_class).once.with("Person", [])
        @parser.parse(@descriptor)
      end

      should "not create any MessageFields" do
        Protopuffs::MessageField.expects(:factory).never
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

      should "create two message classes" do
        Protopuffs::Message::Base.expects(:define_message_class).once.with("Apple", []).in_sequence
        Protopuffs::Message::Base.expects(:define_message_class).once.with("Orange", []).in_sequence
        @parser.parse(@descriptor)
      end

      should "not create any MessageFields" do
        Protopuffs::MessageField.expects(:factory).never
        @parser.parse(@descriptor)
      end
    end


    context "with a Person message including a name field" do
      setup do
        @descriptor = <<-proto
          message Person {
            required string name = 1;
          }
        proto
      end

      should "create one 'Person' message class with one field" do
        Protopuffs::Message::Base.expects(:define_message_class).once.with("Person", responds_with(:size, 1))
        @parser.parse(@descriptor)
      end

      should "create one MessageField with correct options" do
        Protopuffs::MessageField.expects(:factory).once.with("string", "required", "name", 1, nil).
          returns(stub(:tag => 1, :identifier => "name"))
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

      should "create one 'Person' message class with three fields" do
        Protopuffs::Message::Base.expects(:define_message_class).once.with("Person", responds_with(:size, 3))
        @parser.parse(@descriptor)
      end

      should "create three MessageFields with correct options" do
        Protopuffs::MessageField.expects(:factory).once.with("string", "required", "name", 1, nil).in_sequence.
          returns(stub(:tag => 1, :identifier => "name"))
        Protopuffs::MessageField.expects(:factory).once.with("int32", "required", "id", 2, nil).in_sequence.
          returns(stub(:tag => 2, :identifier => "id"))
        Protopuffs::MessageField.expects(:factory).once.with("string", "optional", "email", 3, nil).in_sequence.
          returns(stub(:tag => 3, :identifier => "email"))
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

      should "create one 'Person' message class with three fields" do
        Protopuffs::Message::Base.expects(:define_message_class).once.with("Person", responds_with(:size, 3))
        @parser.parse(@descriptor)
      end

      should "create three MessageFields with correct options" do
        Protopuffs::MessageField.expects(:factory).once.with("string", "required", "name", 1, nil).in_sequence.
          returns(stub(:tag => 1, :identifier => "name"))
        Protopuffs::MessageField.expects(:factory).once.with("string", "optional", "language", 2, "en").in_sequence.
          returns(stub(:tag => 2, :identifier => "language"))
        Protopuffs::MessageField.expects(:factory).once.with("int32", "optional", "account_code", 3, 0).in_sequence.
          returns(stub(:tag => 3, :identifier => "account_code"))
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

      should "create one 'Person' message class with two fields" do
        Protopuffs::Message::Base.expects(:define_message_class).once.with("Person", responds_with(:size, 2))
        @parser.parse(@descriptor)
      end

      should "create two MessageFields with correct options" do
        Protopuffs::MessageField.expects(:factory).once.with("string", "required", "name", 1, nil).in_sequence.
          returns(stub(:tag => 1, :identifier => "name"))
        Protopuffs::MessageField.expects(:factory).once.with("Address", "repeated", "addresses", 2, nil).in_sequence.
          returns(stub(:tag => 2, :identifier => "addresses"))
        @parser.parse(@descriptor)
      end
    end
  end

end
