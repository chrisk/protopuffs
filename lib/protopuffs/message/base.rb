module Protopuffs
  module Message

    class Base

      class << self
        attr_reader :fields

        def define_message_class(name, fields)
          name = name.capitalize
          self.check_fields_for_errors(name, fields)
          Message.send(:remove_const, name) if Message.const_defined?(name)
          klass = Message.const_set(name, Class.new(self))
          klass.instance_variable_set(:@fields, fields)
          fields.each do |field|
            klass.send(:attr_accessor, field.identifier.downcase)
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

      def initialize
        if self.class == Base
          raise "#{self.class} should not be instantiated directly. Use the factory #{self.class}.define_message_class instead."
        end
      end

      def to_wire_format
        self.class.fields.map { |f| f.to_wire_format_with_value(send(f.identifier.downcase)) }.join
      end

    end

  end
end
