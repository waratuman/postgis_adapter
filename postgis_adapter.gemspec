require_relative "lib/active_record/connection_adapters/postgis/version"

Gem::Specification.new do |spec|
  spec.name          = "postgis_adapter"
  spec.version       = ActiveRecord::ConnectionAdapters::PostGIS::VERSION
  spec.authors       = ["James Bracy"]
  spec.email         = ["waratuman@gmail.com"]
  spec.description   = %q{ActiveRecord PostGIS Database Adapter}
  spec.summary       = %q{ActiveRecord PostGIS Database Adapter}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'pg', '~> 1.1'
  spec.add_runtime_dependency 'activerecord', '>= 7.2'
  spec.add_runtime_dependency 'rgeo', '~> 3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'debug'
end
