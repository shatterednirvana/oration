require "bundler/gem_tasks"

require 'rspec/core/rake_task'
task :default => :spec
RSpec::Core::RakeTask.new

require 'rdoc/task'
Rake::RDocTask.new :rdoc do |rdoc|
  rdoc.title = 'Oration'
  rdoc.rdoc_files = ['lib']
  rdoc.rdoc_dir = 'doc'
end
