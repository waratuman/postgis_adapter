lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "postgresql-postgis-extension"
  spec.version       = '0.0.1'
  spec.authors       = ["James R. Bracy"]
  spec.email         = ["waratuman@gmail.com"]
  spec.description   = %q{ActiveRecord PostgreSQLAdapter extensions for PostGIS}
  spec.summary       = %q{ActiveRecord PostgreSQLAdapter extensions for PostGIS}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activerecord', '~> 4.2.0.beta1'
  spec.add_runtime_dependency 'activesupport', '~> 4.2.0.beta1'
  spec.add_runtime_dependency 'rgeo', '~> 0.3.20'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'pg'

end
