#require 'awesome_print'
class SirCachelot
  
  BACKENDS = {
      ram_cache:   Sir::Backends::RamCache,
      redis_cache: Sir::Backends::RedisCache
  }

  @backend = nil

  DEFAULT_CONFIG = {
      logger:         Sir::NakedLogger.new(info: true, debug: true),
      backend:        Sir::Backends::RamCache.new,
      namespace:      self.name,
      default_expiry: 3600,  #Integer(1.hour)
  }

  @configuration = nil

  def initialize(&block)
    @configuration = DEFAULT_CONFIG
    configure(&block)
  end

  # Configuration function
  # yields a config block, see README
  # @returns true
  def configure(&block)

    if block_given?
      yield(@configuration)
    end

    #ap @configuration

    @backend = c(:backend)

    # this doesnt work right
    #Sir::Backends::Base::EXPORTS.each do |func|
    #  Sir.send :define_singleton_method, func do |*params|
    #    @backend.send(func, *params)
    #  end
    #  annoy("Attached #{func}")
    #end

    debug("SirCachealot #{Sir::VERSION} loaded configuration for #{c(:backend).class.name}, watching #{c(:backend).class::EXPORTS.length} methods")
    annoy("Annoy activated! Bwahaha!")
    return true

  end


  # # Tests is debug flag is set
  # # @returns [boolean] debug status
  # def debug?
  #   return c(:debug)
  # end


  # # Tests if annoy flag is set
  # # @returns [boolean] annoy status
  # def annoy?
  #   return c(:annoy)
  # end

  # look up value of single configuration option
  def config(key)
    return c(key)
  end

  # dump config to $stdout
  def dump_config
    p c
    return nil
  end


  # TODO: define all these methods on configure(), we should only go here if the user hasnt configured Sir
  # catch on use if unconfigured
  def method_missing(meth, *args, &block)

    if @backend.class::EXPORTS.include?(meth)
      #configure! if @configuration.nil?
      return @backend.send(meth, *args, &block)
    else
      super
    end

  end

  #remove me
  #
  # @todo Remove me
  # def conredis
  #   require 'redis'
  #   redis_obj        = Redis.new(:host => "127.0.0.1", :port => "6379")
  #   opts             = Sir::Backends::RedisCache::DEFAULTS
  #   opts[:redis_obj] = redis_obj
  #
  #
  #   Sir.configure do |config|
  #     config[:mode]           = :redis_cache
  #     config[:debug]          = true
  #     config[:options]        = opts
  #   end
  #
  # end


  private

  # Send message to debug stream
  def debug(msg)
    (c :logger).debug(msg)
  end


  # Send message to annoy stream
  def annoy(msg)
    (c :logger).debug("(ANNOY) #{msg}")
  end


  def puke
    raise TypeError, "Invalid config(:mode). Check the inputs sent to Sir.configure()"
  end


  def crude_clone(obj)
    return Marshal.load(Marshal.dump(obj))
  end

  # returns a namespaced key
  def nsed_key(key)
    return "#{c(:namespace)}-#{key}"
  end

  # shortcut for @configuration
  def c(key = nil)
    return @configuration if key.nil?
    return @configuration[key]
  end

end