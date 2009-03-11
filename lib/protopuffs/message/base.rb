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

      def initialize
        if self.class == Base
          raise "#{self.class} should not be instantiated directly. Use the factory #{self.class}.define_message_class instead."
        end
        @buffer = StringIO.new
      end

      def to_wire_format
        self.class.fields.each do |field|
          value = send(field.identifier)
          @buffer.write field.to_wire_format_with_value(value) unless value.nil?
        end
        @buffer.string
      end

      def from_wire_format(buffer)
        @buffer = buffer
        until @buffer.eof?
          tag, value_bytes = MessageField.shift_tag_and_value_bytes(@buffer)
          field = self.class.fields.find { |field| field.tag == tag }
          next if field.nil?

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
      end

      def set_values_for_missing_optional_fields
        self.class.fields.select { |field| field.optional? }.each do |field|
          send("#{field.identifier}=", field.default) if send(field.identifier).nil?
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
