require "sir_cachealot/version"

module Sir

	RAM = :ram_cache
	REDIS = :redis_cache
	
	@@redis_driver = nil

	@@ram_cache = { }

	@@configuration = {
		mode:           RAM,
		debug:          false,
		annoy:          false, #super annoying debug messages
		default_expiry: 3600, #Integer(1.hour),
		delete_on_nil:  true,
		use_redis_obj:	nil
	}

	#Configuration parameters
	# configure() yields a block, as per convention
	# configure(key) returns the value of key, or nil
	# configure(key, value) sets key to value
	def self.configure(key = nil, value = nil)

		key = key.downcase.to_sym unless key.nil?

		if !key.nil? && !value.nil?
			@@configuration[key] = value
			
			if key == :use_redis_obj
				self::set_redis_obj(val)
			end
			
			return value

		elsif !key.nil? && value.nil?
			return @@configuration[key]

		elsif key.nil? && value.nil?
			yield(@@configuration)

			#normalize keynames
			@@configuration.keys.each do |k|

				knew = k.downcase.to_sym

				unless knew == k
					@@configuration[knew] = @@configuration[k]
					@@configuration.delete(k)
				end

				if knew == :use_redis_obj
					self::set_redis_obj(@@configuration[knew])
				end

			end

		end

	end


	class << self
		alias :config :configure
	end


	# Gets value for supplied key
	# Returns nil if empty or expired
	def self.get(key, copy = false)

		to_ret = nil

		case config(:mode)
			when RAM
				if x = @@ram_cache[key]
					if x[:expiry].nil? || x[:expiry] > Time.now
						to_ret = x[:value]
					else
						# cache entry is stale
						puts ("          SirCachealot: Cache entry <#{key}> expired at #{x[:expiry]}. Deleting...") if config(:debug)
						@@ram_cache.delete(key)
					end
				end
				
			when REDIS
				key = self::nsed_key(key)
				to_ret = Marshal.load( @@redis_driver.get(key) )

			else
				puke
		end

		if copy && config(:mode) == RAM
			to_ret = self.crude_clone(to_ret)
		end

		if to_ret.nil? && block_given?
			to_ret = yield
		end

		return to_ret

	end


	# deletes the specified key from the cache.
	# returns true if successful, false if not found
	def self.delete(key)

		case config(:mode)
			when RAM
				if @@ram_cache.has_key?(key)
					@@ram_cache.delete(key)
					return true
				end
			when REDIS
				if @@redis_driver.del( self::nsed_key(key) )
					return true
				end
			else
				puke
		end

	end


	# Puts value in cache, key is param key
	# Param expiry is optional, it can be a relative or absolute Fixnum or Time object
	# Returns the value you put into it, unless config(:delete_on_nil) == true and value == nil.
	# Returns true (because it deleted the key) if config(:delete_on_nil) == true and value == nil.
	def self.put(key, value, expiry = config(:default_expiry))

		case expiry.class.name
			when "Fixnum"
				true
			when "Time"
				expiry = Integer(expiry)
			when "NilClass"
				true
			else
				raise ArgumentError, "Expiry must be a Fixnum or Time object"
		end


		unless (!expiry.nil? && expiry > Integer(Time.now))
			expiry = Time.now + expiry
		end

		puts "          SirCachealot: Will expire <#{key}> at #{expiry}" if config(:annoy) == true

		if config(:delete_on_nil) == true && value == nil
			self.delete(key)
		else
			case config(:mode)
				when RAM
					@@ram_cache[key]          ||= { }
					@@ram_cache[key][:value]  = value
					@@ram_cache[key][:expiry] = expiry
					return value

				when REDIS
					key = self::nsed_key(key)
					@@redis_driver.set(key, Marshal.dump(value) )
					@@redis_driver.expireat(key, expiry) unless expiry == nil
					return value
					
				else
					puke
			end
		end


	end


	# Gets the qty of keys in the cache
	def self.size?

		case config(:mode)
			when RAM
				return @@ram_cache.count
			else
				puke
		end

	end


	# Dumps list of cache keys to console, with their value's class.name and expiry
	def self.dump

		case config(:mode)
			when RAM
				@@ram_cache.each do |k, v|
					puts("%-20s %-20s %20s" % [k, v[:value].class, v[:expiry]])
				end
			when REDIS
				raise ArgumentError, "This command not available in REDIS mode"
			else
				puke
		end


		return nil

	end


	# Clears the cache, erases all cache entries
	def self.clear

		case config(:mode)
			when RAM
				@@ram_cache = { }
			when REDIS
				raise ArgumentError, "This command not available in REDIS mode"
			else
				puke
		end

	end


	# Sweeps the cache for expired keys and purges them. NOT THREAD-SAFE!
	def self.clean

		case config(:mode)

			when RAM
				@@ram_cache.each_key do |k|
					if !@@ram_cache[k][:expiry].nil? && @@ram_cache[k][:expiry] < Time.now
						puts("          SirCachealot: Cleaned #{k}") if config(:debug)
						@@ram_cache.delete(k)
					end
				end
			when REDIS
				raise ArgumentError, "This command not available in REDIS mode"
			else
				puke
		end

	end


	private

	def self.set_redis_obj(value)
		if value.class.name == "Redis"
			@@configuration[:mode] = REDIS
			@@redis_driver = @@configuration[:use_redis_obj] 
		else
			if @@configuration[:mode] == REDIS
				raise ArgumentError, "use_redis_obj must be of class Redis"
			end
			
		end
	end

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