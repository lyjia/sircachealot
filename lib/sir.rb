#require "rubygems"
require "sir/version"
require "sir/backends"
require "sir_cachelot"
# $stderr.puts "====================== Load path is:"
# $stderr.puts $LOAD_PATH

# def required(str)
#   require File.dirname(__FILE__) + "/" + str
# end


module Sir
  @sir = SirCachelot.new
end