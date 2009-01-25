require File.dirname(__FILE__) + '/test_helper'

class ParserTest < Test::Unit::TestCase

  context "a proto with an empty Person message" do
    setup do
      Treetop.load "lib/parser/protocol_buffer"
      parser = ProtocolBufferParser.new
      @proto = parser.parse("message Person {}")
    end

    should "have one message" do
      assert_equal 1, @proto.messages.size
    end

    should "have a message named Person" do
      assert_equal "Person", @proto.messages.first.name
    end

    should "have an empty body" do
      assert @proto.messages.first.body.empty?
    end
  end


  context "a proto with two empty messages Apple and Orange" do
    setup do
      Treetop.load "lib/parser/protocol_buffer"
      parser = ProtocolBufferParser.new
      @proto = parser.parse(<<-proto)
        message Apple {}
        message Orange {}
      proto
    end

    should "have two messages" do
      assert_equal 2, @proto.messages.size
    end

    should "have messages named Apple and Orange" do
      assert_equal %w(Apple Orange), @proto.messages.map { |m| m.name }.sort
    end

    should "have messages with empty bodes" do
      assert @proto.messages.all? { |m| m.body.empty? }
    end
  end


  context "a proto with a Person message including a name field" do
    setup do
      Treetop.load "lib/parser/protocol_buffer"
      parser = ProtocolBufferParser.new
      @proto = parser.parse(<<-proto)
        message Person {
          required string name = 1;
        }
      proto
    end

    should "have one message named person" do
      assert_equal 1, @proto.messages.size
      assert_equal "Person", @proto.messages.first.name
    end

    should "have one required string field called name with tag 1" do
      fields = @proto.messages.first.body.fields
      assert_equal 1, fields.size
      assert_equal "required", fields.first.modifier.text_value
      assert_equal "string", fields.first.type.text_value
      assert_equal "name", fields.first.identifier.text_value
      assert_equal "1", fields.first.integer.text_value
    end
  end


  context "a proto with a Person message including three fields" do
    setup do
      Treetop.load "lib/parser/protocol_buffer"
      parser = ProtocolBufferParser.new
      @proto = parser.parse(<<-proto)
        message Person {
          required string name = 1;
          required int32 id = 2;
          optional string email = 3;
        }
      proto
    end

    should "have one message named person" do
      assert_equal 1, @proto.messages.size
      assert_equal "Person", @proto.messages.first.name
    end

    should "have three fields with correct components" do
      fields = @proto.messages.first.body.fields
      assert_equal 3, fields.size
      actual = fields.map { |f| [f.modifier, f.type, f.identifier, f.integer].map { |el| el.text_value } }
      expected = [ %w(required string name 1),
                   %w(required int32 id 2),
                   %w(optional string email 3) ]
      assert_equal expected, actual
    end
  end


  context "a proto with a Person message including two fields with defaults and one without" do
    setup do
      Treetop.load "lib/parser/protocol_buffer"
      parser = ProtocolBufferParser.new
      @proto = parser.parse(<<-proto)
        message Person {
          required string name = 1;
          optional string language = 2 [default = "en"];
          optional int32 account_code = 3 [default = 0];
        }
      proto
    end

    should "have one message named person" do
      assert_equal 1, @proto.messages.size
      assert_equal "Person", @proto.messages.first.name
    end

    should "have three fields with correct components" do
      fields = @proto.messages.first.body.fields
      assert_equal 3, fields.size
      actual = fields.map { |f| [f.modifier, f.type, f.identifier, f.integer, f.default] }
      actual.map! { |f| f.map! { |el| el.respond_to?(:text_value) ? el.text_value : el } }
      expected = [ ["required", "string", "name", "1", nil],
                   ["optional", "string", "language", "2", "en"],
                   ["optional", "int32", "account_code", "3", 0] ]
      assert_equal expected, actual
    end
  end

end