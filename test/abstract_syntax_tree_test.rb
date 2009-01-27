require File.dirname(__FILE__) + '/test_helper'

class AbstractSyntaxTreeTest < Test::Unit::TestCase

  context "a protocol buffer descriptor" do
    setup do
      @parser = Protopuffs::Parser::ProtocolBufferDescriptor.new
    end

    context "with an empty Person message" do
      setup do
        @proto = @parser.parse("message Person {}")
      end

      # TODO: AST tests here
    end

    context "with two empty messages Apple and Orange" do
      setup do
        @descriptor = <<-proto
          message Apple {}
          message Orange {}
        proto
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

      should "create one MessageField" do
        Protopuffs::MessageField.expects(:new).once.returns(mock('MessageField instance'))
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

      should "create three MessageFields" do
        Protopuffs::MessageField.expects(:new).times(3).returns(mock('MessageField instance'))
        @parser.parse(@descriptor)
      end
    end

    context "with a Person message including two fields with defaults and one without" do
      setup do
        @proto = @parser.parse(<<-proto)
          message Person {
            required string name = 1;
            optional string language = 2 [default = "en"];
            optional int32 account_code = 3 [default = 0];
          }
        proto
      end

      # TODO: AST tests here
    end


    context "with a message including a user-typed field" do
      setup do
        @proto = @parser.parse(<<-proto)
          message Person {
            required string name = 1;
            repeated Address addresses = 2;
          }
        proto
      end

      # TODO: AST tests here
    end

  end

end