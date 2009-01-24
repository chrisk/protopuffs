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
      @proto = parser.parse("message Apple { }\n\nmessage Orange { }")
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

end