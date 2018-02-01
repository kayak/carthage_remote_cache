require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :spec

Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*_tests.rb']
    t.verbose = true
end
