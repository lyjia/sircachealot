require 'json'

class Sir::Backends::RedisCache < Sir::Backends::Base

  TYPEERROR = "Redis does not need or support this function"

  META = {
      name: "Redis Cache",
      author: "Lyjia"
  }

  DEFAULTS = {
      redis_obj: nil,
      namespace: 'SirCachealot',
      serializer: :marshal
  }

  def initialize(&block)
    @config = DEFAULTS
    @config = configure(&block)
    @redis = @config[:redis_obj]
  end

  def configure(&block)
    if block_given?
      yield(@config)
      return @config
    else
      raise ArgumentError, "Configure requires a block)"
    end

  end

  def get(key)
    invalid = valid?({key: key})
    raise ArgumentError, invalid if invalid

    key = nmespd_key(key)
    got = @redis.get(key)

    unless got.nil?

      case @config[:serializer]
        when :marshal
          return Marshal.load(got)[0]
        when :json
          return JSON.parse(got)[0]
        else
          raise TypeError, "Invalid serializer: #{@config[:serializer]}. You probably want to look at your Sir.configure() statement"
      end

    else
      super
    end
  end


  # @note We wrap `value` in `[ ]` to protect nil values and such from being misinterpreted
  #   JSON in particular: JSON.parse(nil.to_json) #=> JSON::ParserError
  #                   but JSON.parse([nil].to_json) #=> [nil]
  def put(key, value, expiry = Sir.config(:default_expiry))
    invalid = valid?({key: key, value: value, expiry: expiry})
    raise ArgumentError, invalid if invalid

    key = nmespd_key(key)
    ser = nil

    case @config[:serializer]
      when :marshal
        ser = Marshal.dump([value]).to_s
      when :json
        ser = [value].to_json
      else
        raise TypeError, "Invalid serializer: #{@config[:serializer]}. You probably want to look at your Sir.configure() statement"
    end

    @redis.set(key, ser)

    #### This code snippet needs to be DRYed
    expiry = expiry.to_i unless expiry.nil?

    # normalize relative/absolute times to absolute time, skip if expiry = nil
    if !expiry.nil? && Time.now.to_i > expiry
      expiry += Time.now.to_i
    end
    ####

    if expiry == nil
      @redis.persist(key)
    else
      @redis.expireat(key, expiry.to_i)
    end

    return value

  end


  def able?
    return TYPEERROR == @redis.echo(TYPEERROR)
  end


  def kill(key)
    invalid = valid?({key: key})
    raise ArgumentError, invalid if invalid

    if @redis.del(nmespd_key(key))
      return true
    end
  end


  def dump
    raise TypeError, TYPEERROR
  end


  def nuke
    return true if @redis.flushdb
  end


  def sweep(include_nil_expiry = nil)
    raise TypeError, TYPEERROR
  end


  def flush
    return true if @redis.bgsave
  end


  def length
    return @redis.dbsize
  end


  def keys(mask = "*")
    return @redis.keys(mask).map { |x| x.gsub(/^#{nmespd_key(nil)}\-/, '').intern }
  end


  def post_configure
    @redis = @config[:redis_obj]
  end


  private

  # @returns the namespace name if key is nil
  # @returns a namespaced key otherwise
  def nmespd_key(key)
    return @config[:namespace] if key.nil?
    return "#{@config[:namespace]}-#{key}"
  end


end