# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sir_cachealot/version'

Gem::Specification.new do |gem|
  gem.name          = "SirCachealot"
  gem.version       = SirCachealot::VERSION
  gem.authors       = ["Lyjia"]
  gem.email         = ["tom@tomcorelis.com"]
  gem.description   = %q{A dead simple RAM keystore}
  gem.summary       = %q{SirCachealot is a drop-in memcache-like RAM cache for Ruby. Cache entries are saved and recalled by a key string, and their values can be whatever a Ruby hash can hold. Values can also expire, however expiration is only checked when the key is called, or a manual sweeper is run. }
  gem.homepage      = "http://www.lyjia.us"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec', '~> 2.5'

end
