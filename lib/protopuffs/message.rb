module Protopuffs

  class Message
    attr_reader :name, :fields

    def initialize(name, fields)
      @name = name
      @fields = fields
    end
  end

end
