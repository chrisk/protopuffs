# encoding: UTF-8

module Protopuffs
  module Message

    class Base

      class << self
        attr_reader :fields

        def define_message_class(name, fields)
          name = name.delete("_")
          self.check_fields_for_errors(name, fields)
          Message.send(:remove_const, name) if Message.const_defined?(name)
          klass = Message.const_set(name, Class.new(self))
          klass.instance_variable_set(:@fields, fields)
          fields.each do |field|
            klass.send(:attr_accessor, field.identifier)
          end
          klass
        end

        def check_fields_for_errors(name, fields)
          tags = fields.map { |field| field.tag }
          if tags.uniq.size != fields.size
            raise ParseError, "A tag was reused in the descriptor for message #{name}. Please check that each tag is unique."
          end

          if tags.any? { |tag| tag < 1 || tag > 536_870_911 }
            raise ParseError, "A tag is out of range in the descriptor for message #{name}. Please check that each tag is in the range 1 <= x <= 536,870,911."
          end

          if tags.any? { |tag| (19000..19999).include?(tag) }
            raise ParseError, "A tag is invalid in the descriptor for message #{name}. Please check that each tag is not in the reserved range 19,000 <= x <= 19,999."
          end
        end
      end

      attr_reader :buffer

      def initialize(field_values = nil)
        if self.class == Base
          raise "#{self.class} should not be instantiated directly. Use the factory #{self.class}.define_message_class instead."
        end

        if field_values.nil?
          @buffer = StringIO.new
          @buffer.set_encoding("BINARY") if @buffer.respond_to?(:set_encoding)
        elsif field_values.respond_to?(:each_pair)
          @buffer = StringIO.new
          @buffer.set_encoding("BINARY") if @buffer.respond_to?(:set_encoding)
          self.attributes = field_values
        else
          from_wire_format(field_values)
        end
      end

      def to_wire_format
        self.class.fields.sort_by { |f| f.tag }.each do |field|
          value = send(field.identifier)
          @buffer.write field.to_wire_format_with_value(value) unless value.nil?
        end
        @buffer.string
      end

      # Returns the protocol buffer text format, which is useful for debugging
      def inspect
        type = self.class.name.split("::").last.downcase
        field_strings = self.class.fields.map { |f| "  #{f.identifier}: #{send(f.identifier).inspect}\n" }
        "#{type} {\n#{field_strings.join}}"
      end

      def from_wire_format(buffer)
        if !buffer.respond_to?(:read)
          buffer.force_encoding("BINARY") if buffer.respond_to?(:force_encoding)
          @buffer = StringIO.new(buffer)
        else
          @buffer = buffer
        end
        @buffer.set_encoding("BINARY") if @buffer.respond_to?(:set_encoding)

        until @buffer.eof?
          tag = MessageField.shift_tag(@buffer)
          field = self.class.fields.find { |f| f.tag == tag }
          next if field.nil?
          value_bytes = field.class.shift(@buffer)

          value = field.decode(value_bytes)
          if field.repeated? && send(field.identifier).nil?
            send("#{field.identifier}=", [value])
          elsif field.repeated?
            send(field.identifier) << value
          else
            send("#{field.identifier}=", value)
          end
        end
        set_values_for_missing_optional_fields
        self
      end

      def set_values_for_missing_optional_fields
        self.class.fields.select { |field| field.optional? }.each do |field|
          send("#{field.identifier}=", field.default) if send(field.identifier).nil?
        end
      end

      def attributes=(attrs = {})
        attrs.each_pair do |name, value|
          self.send("#{name}=", value) if respond_to?("#{name}=")
        end
      end

      def ==(other)
        return false if self.class != other.class
        self.class.fields.each do |field|
          return false if send(field.identifier) != other.send(field.identifier)
        end
        true
      end

    end

  end
end
