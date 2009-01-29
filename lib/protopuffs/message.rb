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
      if @fields.map { |f| f.tag }.uniq.size != @fields.size
        raise ParseError, "A tag was reused in the descriptor for message #{@name}. Please check that each tag is unique."
      end
    end
  end

end
