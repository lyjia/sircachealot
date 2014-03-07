# -*- encoding: utf-8 -*-
dir = "#{File.expand_path(File.dirname(__FILE__))}/lib" # gem build doesn't add /lib to load path??
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
require 'sir/version'

#$stderr.puts $LOAD_PATH

Gem::Specification.new do |gem|

  gem.name          = "sir_cachealot"
  gem.licenses      = ["BSD-2-Clause"]
  gem.version       = Sir::VERSION

  gem.authors       = ["Lyjia / Tom Corelis"]
  gem.email         = ["tom@tomcorelis.com"]
  
  gem.description   = %q{A dead simple RAM keystore}
  gem.summary       = %q{ SirCachealot is a drop-in memcache-like RAM cache for Ruby. Cache entries are saved and recalled by a key string, and their values can hold (most) anything a Ruby object can hold. Values can also expire, however expiration is only checked when the key is called, or a manual sweeper is run. }
  gem.homepage      = "https://github.com/lyjia/sircachealot"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'redis', '~> 3.0.7'
  gem.add_development_dependency 'rspec', '~> 2.5'
  gem.add_development_dependency 'awesome_print'

end
