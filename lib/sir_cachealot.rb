require "sir_cachealot/version"

module Sir

  RAM = :ram_cache

  @@ram_cache = { }

  @@configuration = {
    mode:           RAM,
    debug:          false,
    annoy:          false, #super annoying debug messages
    default_expiry: 3600, #Integer(1.hour),
    delete_on_nil:  true

  }

  #Configuration parameters
  # configure() yields a block, as per convention
  # configure(key) returns the value of key, or nil
  # configure(key, value) sets key to value
  def self.configure(key = nil, value = nil)

    key = key.downcase.to_sym unless key.nil?

    if !key.nil? && !value.nil?
      @@configuration[key] = value
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

      end

    end

  end

  class << self
    alias :config :configure
  end


  # Gets value for supplied key
  # Returns nil if empty or expired
  def self.get(key)

    case config(:mode)
    when RAM

      if x = @@ram_cache[key]

        if x[:expiry].nil? || x[:expiry] > Time.now
          return x[:value]
        else
          # cache entry is stale
          puts ("          SirCachealot: Cache entry <#{key}> expired at #{x[:expiry]}. Deleting...") if config(:debug)
          @@ram_cache.delete(key)
          if block_given?
            yield
          else
            nil
          end
        end

      else

        if block_given?
          yield
        else
          return nil
        end
      end

    else
      puke
    end

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
    else
      puke
    end

  end

  private

  def self.puke
    raise TypeError, "Invalid config(:mode). Check the inputs sent to Sir.configure()"
  end

end
