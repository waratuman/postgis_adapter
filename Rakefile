require 'rake/testtask'
require 'bundler/gem_tasks'

desc "Run tests"
Rake::TestTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.warning = true
  test.verbose = true
end
