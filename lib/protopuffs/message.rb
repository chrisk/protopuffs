module Protopuffs

  class Message
    attr_reader :name, :fields

    def initialize(name, fields)
      @name = name
      @fields = fields
      check_fields_for_errors
    end


    private

    def check_fields_for_errors
      tags = @fields.map { |field| field.tag }
      if tags.uniq.size != @fields.size
        raise ParseError, "A tag was reused in the descriptor for message #{@name}. Please check that each tag is unique."
      end

      if tags.any? { |tag| tag < 1 || tag > 536_870_911 }
        raise ParseError, "A tag is out of range in the descriptor for message #{@name}. Please check that each tag is in the range 1 <= x <= 536,870,911."
      end

      if tags.any? { |tag| (19000..19999).include?(tag) }
        raise ParseError, "A tag is invalid in the descriptor for message #{@name}. Please check that each tag is not in the reserved range 19,000 <= x <= 19,999."
      end
    end
  end

end
