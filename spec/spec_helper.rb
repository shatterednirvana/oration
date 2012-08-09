require 'simplecov'
SimpleCov.start

RSpec.configure do |c|
  if not File.exists?("C:/Program Files/Windows Azure Emulator/emulator/csrun.exe")
    puts "Disabling tests that require Windows to run"
    c.filter_run_excluding :require_windows => true
  end
  if not ENV["AZURE_STORAGE_ACCOUNT_NAME"] or not ENV["AZURE_STORAGE_ACCESS_KEY"]
    puts "Disabling tests that require Azure credentials to run"
    c.filter_run_excluding :require_azure_credentials => true
  end
end

# Support

require 'tmpdir'
def get_test_data
  target = Dir.mktmpdir "oration-test-"
  Dir['spec/data/*'].each do |subdir|
    FileUtils.cp_r subdir, target
  end
  target
end
