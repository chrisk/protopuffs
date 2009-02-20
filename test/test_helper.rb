require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'treetop'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'protopuffs'

class Test::Unit::TestCase

  def print_bytes(string)
    puts
    string.each_byte do |byte|
      printf("%1$08b (%1$02X)\n", byte)
    end
  end

end

