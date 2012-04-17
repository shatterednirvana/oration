# Programmer: Chris Bunch

$:.unshift File.join(File.dirname(__FILE__), "..", "bin")
require 'oration'

require 'test/unit'


class FakeFile
  def self.exists?(file_name)
    if file_name.include?("good") or file_name.include?("exists")
      return true
    else
      return false
    end
  end

  def self.open(file_name)
    return "def good-function-name():\n  print 'hello world!'"
  end
end


class TestOration < Test::Unit::TestCase
  def test_validate_arguments
    # test when the file in question doesn't exist
    assert_raise(SystemExit) { 
      validate_arguments('doesnt-exist.go', 'boo', 'output-dir', 'appid', 
        FakeFile) 
    }
    
    # test when the function to be used doesn't exist in that file
    assert_raise(SystemExit) { 
      validate_arguments('good-file.go', 'bad-function-name', 'output-dir', 
        'appid', FakeFile)
    }

    # test when the output-dir specified already exists
    assert_raise(SystemExit) { 
      validate_arguments('good-file.go', 'good-function-name',
        'output-dir-exists', 'appid', FakeFile) 
    }

    # test when the user gives us a file that exists with the named function
    assert_nothing_raised(SystemExit) {
      validate_arguments('good-file.go', 'good-function-name', 'output-dir', 
        'appid', FakeFile)
    }
  end
end
