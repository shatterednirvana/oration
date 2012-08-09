require 'simplecov'
SimpleCov.start

RSpec.configure

# Support

require 'tmpdir'
def get_test_data
  target = Dir.mktmpdir "oration-test-"
  Dir['spec/data/*'].each do |subdir|
    FileUtils.cp_r subdir, target
  end
  target
end
