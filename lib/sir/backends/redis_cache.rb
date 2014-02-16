require 'json'

class Sir::Backends::RedisCache < Sir::Backends::Base

  TYPEERROR = "Redis does not need or support this function"

  META = {
      name:   "Redis Cache",
      author: "Lyjia"
  }

  DEFAULTS = {
      redis_obj:  nil,
      namespace:  'SirCachealot',
      serializer: :marshal
  }

  @@config = DEFAULTS
  @@redis  = @@config[:redis_obj]


  def self.get(key)
    invalid = self.valid?({ key: key })
    raise ArgumentError, invalid if invalid

    key = self::nsed_key(key)
    got = @@redis.get(key)

    unless got.nil?

      case @@config[:serializer]
        when :marshal
          return Marshal.load(got)[0]
        when :json
          return JSON.parse(got)[0]
        else
          raise TypeError, "Invalid serializer: #{@@config[:serializer]}. You probably want to look at your Sir.configure() statement"
      end

    else
      super
    end
  end


  # @note We wrap `value` in `[ ]` to protect nil values and such from being misinterpreted
  #   JSON in particular: JSON.parse(nil.to_json) #=> JSON::ParserError
  #                   but JSON.parse([nil].to_json) #=> [nil]
  def self.put(key, value, expiry = Sir.config(:default_expiry))
    invalid = self.valid?({ key: key, value: value, expiry: expiry })
    raise ArgumentError, invalid if invalid

    key = self::nsed_key(key)
    ser = nil

    case @@config[:serializer]
      when :marshal
        ser = Marshal.dump([value]).to_s
      when :json
        ser = [value].to_json
      else
        raise TypeError, "Invalid serializer: #{@@config[:serializer]}. You probably want to look at your Sir.configure() statement"
    end

    @@redis.set(key, ser)

    #### This code snippet needs to be DRYed
    expiry = expiry.to_i unless expiry.nil?

    # normalize relative/absolute times to absolute time, skip if expiry = nil
    if !expiry.nil? && Time.now.to_i > expiry
      expiry += Time.now.to_i
    end
    ####

    if expiry == nil
      @@redis.persist(key)
    else
      @@redis.expireat(key, expiry.to_i)
    end

    return value

  end


  def self.able?
    return TYPEERROR == @@redis.echo(TYPEERROR)
  end


  def self.kill(key)
    invalid = self.valid?({ key: key })
    raise ArgumentError, invalid if invalid

    if @@redis_driver.del(self::nsed_key(key))
      return true
    end
  end


  def self.dump
    raise TypeError, TYPEERROR
  end


  def self.nuke
    return true if @@redis.flushdb
  end


  def self.sweep(include_nil_expiry = nil)
    raise TypeError, TYPEERROR
  end


  def self.flush
    return true if @@redis.bgsave
  end


  def self.length
    return @@redis.dbsize
  end


  def self.keys(mask = "*")
    return @@redis.keys(mask).map {|x| x.gsub(/^#{self.nsed_key("")}/, '').intern}
  end


  def self.post_configure
    @@redis = @@config[:redis_obj]
  end


  private

  # returns a namespaced key
  def self.nsed_key(key)
    return "#{@@config[:namespace]}-#{key}"
  end


end