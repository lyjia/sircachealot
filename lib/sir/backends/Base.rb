# Base class for all backend implementations
#
# To build a new backend, subcass Sir::Backends::Base (see RamCache for a simple example)
# Backend classes register to Sir by implementing two constants:

#   META: a hash containing useful metadata
#     must have :name, :author keys defined

#   CONFIG: a template of the default configuration hash for this module
#
#
class Sir::Backends::Base
  EXPORTS = [:get, :put, :kill, :dump, :nuke, :sweep, :flush, :able?, :length, :keys]

  ##########################################################
  # IMPLEMENT THESE FUNCTIONS                              #
  ##########################################################

  # Gets a copy of the key from the cache.
  # Yields to a block that should return the value you were looking for. (see #put)
  #
  # Backends implementing #get() *must* call #super if the object is not found (let Base handle that stuff!)
  #
  # @todo 1: Mutiple calls to the same key will return a reference to the original object
  # @param key [symbol] name of your key
  # @return
  #   value if the object was found in the cache, or
  #   value returned by supplied block if the object expired or was not found and a block was supplied, or
  #   nil if object was expired or not found, and no block was supplied
  def self.get(key)

    Sir.annoy("Cache miss on #{key}")

    if block_given?
      Sir.annoy("Block given, yielding to #{key}")
      return yield(key)
    else
      Sir.annoy("No Block given")
      return nil
    end

  end


  # Pings the backend, if applicable
  # @returns true if backend is correctly configured and able to accept requests
  def self.able?
    raise NotImplementedError
  end

  # Puts a key in the cache. Overwrites existing value if already exist
  # @note Recommended to use this function inside a block from #get (see #get)
  # @note It would be a good idea to call #put whenever the object is saved (like :after_save)
  # @caveat Be careful about storing nil values -- nil is returned by get when an object is not found
  # @todo 1: Will invalidate any stored references
  # @param key [symbol] name of your key
  # @return value
  # @raise NotImplementedError if function is not implemented in selected backend module
  def self.put(key, value, expiry)
    raise NotImplementedError
  end


  # Deletes a key in the cache
  # @param key [symbol] name of your key
  # @return true if deleted
  # @raise NotImplementedError if function is not implemented in selected backend module
  def self.kill(key)
    raise NotImplementedError
  end


  # Dumps all keys to console
  # @raise NotImplementedError if function is not implemented in selected backend module
  # @raise TypeError if function is not supported/needed by the backend
  # @return true if success
  def self.dump
    raise NotImplementedError
  end


  # Deletes all keys in backend. CAREFUL!!! (FLUSHDB in Redis)
  # @return [void]
  # @raise NotImplementedError if function is not implemented in selected backend module
  # @raise TypeError if function is not supported/needed by the backend
  # @return true if success
  def self.nuke
    raise NotImplementedError
  end


  # Sweeps all keys and invalidates (ie. #kill) any that have expired. This is only required for backends that do not facilitate automatic key expiration.
  # @note It is important to run #clean() periodically to avoid leaks. (Put this in a cronjob in multiprocess/cluster scenarios)
  # @todo Run this function in a new thread every so often
  # @param include_nil_expiry [Boolean] Also invalidate nil expiry if true
  # @return true if success
  # @raise NotImplementedError if function is not implemented in selected backend module
  # @raise TypeError if function is not supported/needed by the backend
  def self.sweep(include_nil_expiry)
    raise NotImplementedError
  end

  # Ask backend to flush to disk, if supported
  # @raise NotImplementedError if function is not implemented in selected backend module
  # @raise TypeError if function is not supported/needed by the backend
  # @return true if success
  def self.flush
    raise NotImplementedError
  end


  # Gets the number of keys in the cache
  # @return [integer] number of keys in cache
  # @raise NotImplementedError if function is not implemented in selected backend module
  # @raise TypeError if function is not supported/needed by the backend
  def self.length
    raise NotImplementedError
  end

  # List all keys in the cache
  # WARNING: This is slow!
  # @return [array] List of keys
  def self.keys(mask = "*")
    raise NotImplementedError
  end

  # Called immediately after @@config has been set. Child backends should inherit this to react to configuration changes
  def self.post_configure
  end

  ##########################################################
  # DO NOT IMPLEMENT THESE FUNCTIONS                       #
  ##########################################################

  # Sets configuration properties.
  # @param options_hash [hash] should be a (modified, or not) copy of the backend's CONFIG constant
  def self.configure(options_hash)
    Sir.annoy("configure #{options_hash}")
    @@config = options_hash
    self.post_configure
  end

  def self.arity(func)
    method(func).arity
  end

  private

  def self.valid?(hash)
    return "Key must coerce to a symbol" unless hash[:key].respond_to?(:intern) if hash[:key]
    return "Value must be valuable" unless hash[:value] if hash[:value]
    return "Time must be a valid time" unless (hash[:expiry].is_a?(Time) || hash[:expiry].is_a?(Integer)) if hash[:expiry]
  end

end