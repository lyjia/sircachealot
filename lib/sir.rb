#require "rubygems"
require "sir/version"
require "sir/backends"
# $stderr.puts "====================== Load path is:"
# $stderr.puts $LOAD_PATH

# def required(str)
#   require File.dirname(__FILE__) + "/" + str
# end


module Sir

  BACKENDS = {
      ram_cache:   Sir::Backends::RamCache,
      redis_cache: Sir::Backends::RedisCache
  }

  @@backend = Sir::Backends::RamCache

  @@configuration = {
      mode:           :ram_cache,
      debug:          false, #debug messages (prints to stderr)
      annoy:          false, #super annoying debug messages (prints to stderr)
      default_expiry: 3600,  #Integer(1.hour)
      options:        {}
  }


  # Configuration function
  # yields a config block, see README
  # @returns true
  def self.configure(&block)

    if block_given?
      yield(@@configuration)
    end

    #ap @@configuration

    @@backend = BACKENDS[@@configuration[:mode]]
    @@backend.configure(@@configuration[:options])

    # this doesnt work right
    #Sir::Backends::Base::EXPORTS.each do |func|
    #  Sir.send :define_singleton_method, func do |*params|
    #    @@backend.send(func, *params)
    #  end
    #  self.annoy("Attached #{func}")
    #end

    self.debug("SirCachealot #{Sir::VERSION} loaded configuration for #{@@configuration[:mode]}, watching #{Sir::Backends::Base::EXPORTS.length} methods")
    self.annoy("Annoy activated! Bwahaha!")
    return true

  end


  # Tests is debug flag is set
  # @returns [boolean] debug status
  def self.debug?
    return @@configuration[:debug]
  end


  # Tests if annoy flag is set
  # @returns [boolean] annoy status
  def self.annoy?
    return @@configuration[:annoy]
  end


  # Send message to debug stream
  def self.debug(msg)
    $stderr.puts("<=S=I=R=[==] !! #{msg}") if self.debug?
  end


  # Send message to annoy stream
  def self.annoy(msg)
    $stderr.puts("<=S=I=R=[==] - #{msg}") if self.annoy?
  end


  # look up value of single configuration option
  def self.config(key)
    return @@configuration[key]
  end


  def self.dump_config
    p @@configuration
    return nil
  end


  # TODO: define all these methods on configure(), we should only go here if the user hasnt configured Sir
  # catch on use if unconfigured
  def self.method_missing(meth, *args, &block)

    if Sir::Backends::Base::EXPORTS.include?(meth)
      self.configure! if @@configuration.nil?
      return @@backend.send(meth, *args, &block)
    else
      super
    end

  end

  #remove me
  #
  # @todo Remove me
  def self.conredis
    require 'redis'
    redis_obj        = Redis.new(:host => "127.0.0.1", :port => "6379")
    opts             = Sir::Backends::RedisCache::DEFAULTS
    opts[:redis_obj] = redis_obj


    Sir.configure do |config|
      config[:mode]           = :redis_cache
      config[:debug]          = true
      config[:options]        = opts
    end

  end


  private

  def self.puke
    raise TypeError, "Invalid config(:mode). Check the inputs sent to Sir.configure()"
  end


  def self.crude_clone(obj)
    return Marshal.load(Marshal.dump(obj))
  end


# returns a namespaced key
  def self.nsed_key(key)
    return "SirCachealot-#{key}"
  end


end