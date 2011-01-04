require "rake/rdoctask"
require "rspec/core/rake_task"

task :default => [:spec]

RSpec::Core::RakeTask.new(:spec)

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/beway/*.rb")
  rd.rdoc_dir = 'doc'
end
