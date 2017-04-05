require 'time'

class Sir::Backends::RamCache < Sir::Backends::Base

  META = {
      name:   "RAM Cache",
      author: "Lyjia"
  }

  DEFAULTS = {}

  @config    = DEFAULTS
  @ram_cache = {}

  VALUE  = 0
  EXPIRY = 1


  def get(key)
    invalid = valid?({ key: key })
    raise ArgumentError, invalid if invalid

    Sir.annoy("I have a block!") if block_given?

    if x = @ram_cache[key]

      if x[EXPIRY].nil? || x[EXPIRY] > Time.now.to_i

        return x[VALUE]

      else

        # cache entry is stale
        Sir.debug("Cache entry <#{key}> expired at #{x[VALUE]}. Deleting...")
        @ram_cache.delete(key)

        super

      end

    else

      super

    end

  end


  def put(key, value, expiry = Sir.config(:default_expiry))
    invalid = valid?({ key: key, value: value, expiry: expiry })
    raise ArgumentError, invalid if invalid

    #### This code snippet needs to be DRYed
    expiry = expiry.to_i unless expiry.nil?

    # normalize relative/absolute times to absolute time, skip if expiry = nil
    if !expiry.nil? && Time.now.to_i > expiry
      expiry += Time.now.to_i
    end
    ####

    @ram_cache[key] = [value, expiry]
    return value

  end


  def able?
    return true
  end


  def kill(key)
    invalid = valid?({ key: key })
    raise ArgumentError, invalid if invalid

    if @ram_cache.has_key?(key)
      @ram_cache.delete(key)
      return true
    end

  end


  def dump
    @ram_cache.each { |k, v| $stderr.puts("#{k}: #{v}") }
    return true
  end


  def nuke
    @ram_cache = {}
    return true
  end


  def length
    @ram_cache.length
  end


  def sweep(include_nil_expiry = nil)
    Sir.debug("Invalidating stale keys... (#{@ram_cache.keys.length} keys) #{include_nil_expiry}")

    @ram_cache.each_key do |k|

      if @ram_cache[k][EXPIRY].nil? && include_nil_expiry
        @ram_cache.delete(k)
        next
      end

      @ram_cache.delete(k) if key_expired?(k)

    end

    Sir.debug("Finished! (now #{@ram_cache.keys.length} keys)")
    return true
  end

  MASK = "*"
  def keys(mask = MASK)
    if mask == MASK
      return @ram_cache.keys
    else
      return @ram_cache.keys.bsearch {|x| (x =~ /#{mask}/i) }
    end
  end

  private

  def key_expired?(key)

    if x = @ram_cache[key]

      ans = nil
      ans = false if x[EXPIRY].nil?

      if ans.nil? && x[EXPIRY].to_i <= Time.now.to_i
        ans = true
      else
        ans = false
      end

      Sir.debug("comparing #{x[EXPIRY]} to time #{Time.now.to_i} (#{ans})")
      return ans

    else
      raise ArgumentError, "Key not found"
    end

  end

end