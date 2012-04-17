require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = 'oration'
  s.version = '0.0.4'

  s.summary = "Generates Cicero-ready Google App Engine apps from regular code"
  s.description = <<-EOF
    Oration converts a function written in Python or Go into a Google App Engine
    application that conforms to the Cicero API, allowing the given function to
    be automatically executed over Google App Engine or AppScale in an
    embarrassingly parallel fashion.
  EOF

  s.author = "Chris Bunch"
  s.email = "appscale_community@googlegroups.com"
  s.homepage = "http://appscale.cs.ucsb.edu"

  s.executables = ["oration"]
  s.default_executable = 'oration'
  s.platform = Gem::Platform::RUBY

  candidates = Dir.glob("{bin,doc,lib,test,templates}/**/*")
  s.files = candidates.delete_if do |item|
    item.include?(".bzr") || item.include?("rdoc")
  end
  s.require_path = "lib"
  s.autorequire = "oration"

  s.has_rdoc = true
  s.extra_rdoc_files = ["LICENSE"]

  s.add_dependency('optiflag', '>= 0.7')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

