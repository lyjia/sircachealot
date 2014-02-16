require "rubygems"

require "sir/version"
require "sir/backends"
require "awesome_print"

module Sir

  BACKENDS = {
      ram_cache:   Sir::Backends::RamCache,
      redis_cache: Sir::Backends::RedisCache
  }

  @@backend = Sir::Backends::RamCache

  @@configuration = {
      mode:           :ram_cache,
      debug:          false,
      annoy:          false, #super annoying debug messages
      default_expiry: 3600, #Integer(1.hour)
      options:        {}
  }


  # Configuration function
  # yields a config block, see README
  # @returns true
  def self.configure(&block)

    if block_given?
      yield(@@configuration)
    end

    ap @@configuration

    @@backend       = BACKENDS[@@configuration[:mode]]

    # this doesnt work right
    #Sir::Backends::Base::EXPORTS.each do |func|
    #  Sir.send :define_singleton_method, func do |*params|
    #    @@backend.send(func, *params)
    #  end
    #  self.annoy("Attached #{func}")
    #end

    self.debug("SirCachealot #{Sir::VERSION} loaded configuration, defined #{Sir::Backends::Base::EXPORTS.length} methods")
    self.annoy("Annoy activated!")
    return true

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


  class << self
    alias :config :configure
  end


  def self.debug?
    return @@configuration[:debug]
  end


  def self.annoy?
    return @@configuration[:annoy]
  end


  def self.debug(msg)
    $stderr.puts("<=S=I=R=[==] ! #{msg}") if self.debug?
  end


  def self.annoy(msg)
    $stderr.puts("<=S=I=R=[==] : #{msg}") if self.annoy?
  end

  def self.config(key)
    return @@configuration[key]
  end


## Gets value for supplied key
## Returns nil if empty or expired
#def self.get(key, copy = false)
#
#	to_ret = nil
#
#	case config(:mode)
#		when RAM
#			if x = @@ram_cache[key]
#				if x[:expiry].nil? || x[:expiry] > Time.now
#					to_ret = x[:value]
#				else
#					# cache entry is stale
#					puts ("          SirCachealot: Cache entry <#{key}> expired at #{x[:expiry]}. Deleting...") if config(:debug)
#					@@ram_cache.delete(key)
#				end
#			end
#
#		when REDIS
#			key = self::nsed_key(key)
#			got = @@redis_driver.get(key)
#
#			unless got.nil?
#				to_ret = Marshal.load( got )
#			else
#				to_ret = nil
#			end
#		else
#			puke
#	end
#
#	if copy && config(:mode) == RAM
#		to_ret = self.crude_clone(to_ret)
#	end
#
#	if to_ret.nil? && block_given?
#		to_ret = yield
#	end
#
#	return to_ret
#
#end
#
#
## deletes the specified key from the cache.
## returns true if successful, false if not found
#def self.delete(key)
#
#	case config(:mode)
#		when RAM
#			if @@ram_cache.has_key?(key)
#				@@ram_cache.delete(key)
#				return true
#			end
#		when REDIS
#			if @@redis_driver.del( self::nsed_key(key) )
#				return true
#			end
#		else
#			puke
#	end
#
#end
#
#
## Puts value in cache, key is param key
## Param expiry is optional, it can be a relative or absolute Fixnum or Time object
## Returns the value you put into it, unless config(:delete_on_nil) == true and value == nil.
## Returns true (because it deleted the key) if config(:delete_on_nil) == true and value == nil.
#def self.put(key, value, expiry = config(:default_expiry))
#
#	case expiry.class.name
#		when "Fixnum"
#			true
#		when "Time"
#			expiry = Integer(expiry)
#		when "NilClass"
#			true
#		else
#			raise ArgumentError, "Expiry must be a Fixnum or Time object"
#	end
#
#
#	unless (!expiry.nil? && expiry > Integer(Time.now))
#		expiry = Time.now + expiry
#	end
#
#	puts "          SirCachealot: Will expire <#{key}> at #{expiry}" if config(:annoy) == true
#
#	if config(:delete_on_nil) == true && value == nil
#		self.delete(key)
#	else
#		case config(:mode)
#			when RAM
#				@@ram_cache[key]          ||= { }
#				@@ram_cache[key][:value]  = value
#				@@ram_cache[key][:expiry] = expiry
#				return value
#
#			when REDIS
#				key = self::nsed_key(key)
#				@@redis_driver.set(key, Marshal.dump(value).to_s )
#				#$stderr.puts "Will expire at #{expiry}"
#				@@redis_driver.expireat(key, expiry.to_i) unless expiry == nil
#				return value
#
#			else
#				puke
#		end
#	end
#
#
#end
#
#
## Gets the qty of keys in the cache
#def self.size?
#
#	case config(:mode)
#		when RAM
#			return @@ram_cache.count
#		when REDIS
#			return :not_possible
#		else
#			puke
#	end
#
#end
#
#
## Dumps list of cache keys to console, with their value's class.name and expiry
#def self.dump
#
#	case config(:mode)
#		when RAM
#			@@ram_cache.each do |k, v|
#				puts("%-20s %-20s %20s" % [k, v[:value].class, v[:expiry]])
#			end
#		when REDIS
#			raise ArgumentError, "This command not available in REDIS mode"
#		else
#			puke
#	end
#
#
#	return nil
#
#end
#
#
## Clears the cache, erases all cache entries
#def self.clear
#
#	case config(:mode)
#		when RAM
#			@@ram_cache = { }
#		when REDIS
#			raise ArgumentError, "This command not available in REDIS mode"
#		else
#			puke
#	end
#
#end
#
#
## Sweeps the cache for expired keys and purges them. NOT THREAD-SAFE!
#def self.clean
#
#	case config(:mode)
#
#		when RAM
#			@@ram_cache.each_key do |k|
#				if !@@ram_cache[k][:expiry].nil? && @@ram_cache[k][:expiry] < Time.now
#					puts("          SirCachealot: Cleaned #{k}") if config(:debug)
#					@@ram_cache.delete(k)
#				end
#			end
#		when REDIS
#			raise ArgumentError, "This command not available in REDIS mode"
#		else
#			puke
#	end
#
#end

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