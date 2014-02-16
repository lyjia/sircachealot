class Sir::Backends::RedisCache < Sir::Backends::Base

  META = {
      name: "Redis Cache",
      author: "Lyjia"
  }

  DEFAULTS = {
      redis_obj: nil
  }

  @@config = nil
  @@redis = nil

  def self.get(key)
    raise NotImplementedError
  end

  def self.put(key, value, expiry)
    raise NotImplementedError
  end

  def self.kill(key)
    raise NotImplementedError
  end

  def self.dump
    raise NotImplementedError
  end

  def self.nuke
    raise NotImplementedError
  end

  def self.sweep
    raise NotImplementedError
  end

  def self.flush
    raise NotImplementedError
  end

end