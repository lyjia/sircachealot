class Sir::NakedLogger

  def initialize(**args)
    @fatal = args[:fatal]
    @debug = args[:debug]
    @info = args[:info]
    @warn = args[:warn]
    @error = args[:error]
  end

  def self.log(txt, classname)
    $stedd.puts("#{classname}: #{txt}")
  end

  def self.error(txt, classname = "!! ERROR Sir")
    self.log(txt, classname)
  end

  def self.warn(txt, classname = "!! WARN Sir")
    self.log(txt, classname)
  end

  def self.info(txt, classname = "INFO Sir")
    self.log(txt, classname)
  end

  def self.debug(txt, classname = "DEBUG Sir")
    self.log(txt, classname)
  end

  def method_missing(m, *args, &block)
    m = m.to_sym unless m.class
    if [:debug, :info, :warn, :error].include?(m)
      return instance_variable_get("@#{m}")
    end
  end

end