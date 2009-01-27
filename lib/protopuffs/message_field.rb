module Protopuffs

  class MessageField
    attr_reader :modifier, :type, :identifier, :tag, :default

    def initialize(modifier, type, identifier, tag, default)
      @modifier = modifier
      @type = type
      @identifier = identifier
      @tag = tag
      @default = default
    end
  end

end
