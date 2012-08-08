require 'rdoc/task'

task :default =>: test
task :test do
  sh 'ruby test/ts_all.rb'
end

Rake::RDocTask.new :rdoc do |rdoc|
  rdoc.title = 'Oration'
  rdoc.rdoc_files = ['lib']
  rdoc.rdoc_dir = 'doc'
end
