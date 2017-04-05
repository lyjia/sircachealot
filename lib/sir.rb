#require "rubygems"
require "sir/version"
require "sir/backends"
require "sir/naked_logger"
require "sir_cachealot"
# $stderr.puts "====================== Load path is:"
# $stderr.puts $LOAD_PATH

# def required(str)
#   require File.dirname(__FILE__) + "/" + str
# end


module Sir
  @sir = SirCachelot.new

  def self.configure(&block)
    @sir.configure(&block)
  end

  def self.method_missing(meth, *args, &block)
    return @sir.send(meth, *args, &block)
  end

end