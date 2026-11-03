source 'https://rubygems.org'

# Specify your gem's dependencies in texticle.gemspec
gemspec

# Lets CI test each supported Rails release, e.g. RAILS_VERSION=8.0
gem 'activerecord', "~> #{ENV['RAILS_VERSION']}.0" if ENV['RAILS_VERSION']
