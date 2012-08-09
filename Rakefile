require 'rspec/core/rake_task'
require 'rdoc/task'

task :default => :spec
RSpec::Core::RakeTask.new

Rake::RDocTask.new :rdoc do |rdoc|
  rdoc.title = 'Oration'
  rdoc.rdoc_files = ['lib']
  rdoc.rdoc_dir = 'doc'
end
