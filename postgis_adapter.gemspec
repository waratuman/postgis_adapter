lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "postgis_adapter"
  spec.version       = '7.0.0.1'
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
  spec.add_runtime_dependency 'activerecord', '>= 7.0'
  spec.add_runtime_dependency 'rgeo', '~> 2.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
end
