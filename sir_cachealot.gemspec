# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sir/version'

Gem::Specification.new do |gem|
  gem.name          = "sir_cachealot"
  gem.licenses      = ["BSD-2-Clause"]
  gem.version       = Sir::VERSION
  gem.authors       = ["Lyjia / Tom Corelis"]
  gem.email         = ["tom@tomcorelis.com"]
  gem.description   = %q{A dead simple RAM keystore}
  gem.summary       = %q{ SirCachealot is a drop-in memcache-like RAM cache for Ruby. Cache entries are saved and recalled by a key string, and their values can hold (most) anything a Ruby object can hold. Values can also expire, however expiration is only checked when the key is called, or a manual sweeper is run. }
  gem.homepage      = "http://www.lyjia.us"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  gem.add_development_dependency 'redis', '~> 3.0.7'

  gem.add_development_dependency 'rspec', '~> 2.5'
  gem.add_development_dependency 'awesome_print'

end
