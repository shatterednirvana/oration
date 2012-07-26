# Programmer: Chris Bunch
require 'generator'

class DoNothingGenerator
  def self.does_nothing(a, b, c, d)
  end
end


class GetPythonFunctionFakeFile
  def self.open(filename)
    case filename
    when "test 1"
      return TEST_PYTHON_FILE1
    when "test 2"
      return TEST_PYTHON_FILE2
    when "test 3"
      return TEST_PYTHON_FILE3
    else
      abort("filename was not an acceptable parameter")
    end
  end
end


PY_FUNCTION = <<PY
def print_hello_world():
  print "hello world!"
PY

TEST_PYTHON_FILE1 = <<PY
#{PY_FUNCTION}
PY

TEST_PYTHON_FILE2 = <<PY
def print_hello_world():
  sleep(1)
  for i in range(5):
    print "hello world!"
PY

TEST_PYTHON_FILE3 = <<PY
import random
import sys
import os

#{PY_FUNCTION}
PY


class GetGoFunctionFakeFile
  def self.open(filename)
    case filename
    when "test 1"
      return TEST_GO_FILE1
    when "test 2"
      return TEST_GO_FILE2
    when "test 3"
      return TEST_GO_FILE3
    else
      abort("filename was not an acceptable parameter")
    end
  end
end


GO_FUNCTION = <<GO
func PrintHelloWorld() string {
  return "Hello world!"
}
GO

TEST_GO_FILE1 = <<GO
#{GO_FUNCTION}
GO

TEST_GO_FILE2 = <<GO
func PrintHelloWorld() string {
  all := ""
  for i := 0; i < 5; i++ {
      all += "Hello world!\n"
  }
  return all
}
GO

GO_FUNCTION_3 = <<GO
func PrintHelloWorld() string {
  return fmt.Sprintf("Hello world %d", 1)
}
GO

TEST_GO_FILE3 = <<GO
import fmt

#{GO_FUNCTION_3}
GO


class GeneratorFakeFile
  def self.expand_path(path)
    return path
  end

  def self.open(location, mode=nil)
    return ""
  end
end


class TestGenerator < Test::Unit::TestCase
  def test_generate_app
    # Slip in a fake method that doesn't do anything since we only want to
    # test the generate_app method, and not methods that actually create a
    # Python or Go application.
    function = "blarg"
    output_dir = "output_dir"
    app_id = "myappid"
    do_nothing_method = DoNothingGenerator.method(:does_nothing)

    # c files aren't supported, so this should fail
    assert_raise(SystemExit) {
      Generator.generate_app("boo.c", function, output_dir, app_id,
        do_nothing_method, do_nothing_method)
    }

    # files with no extension aren't supported, so this should fail
    assert_raise(SystemExit) {
      Generator.generate_app("boo", function, output_dir, app_id,
        do_nothing_method, do_nothing_method)
    }

    # python files are supported, so this should succeed
    assert_nothing_raised(SystemExit) {
      Generator.generate_app("boo.py", function, output_dir, app_id,
        do_nothing_method, do_nothing_method)
    }

    # go files are supported, so this should succeed
    assert_nothing_raised(SystemExit) {
      Generator.generate_app("boo.go", function, output_dir, app_id,
        do_nothing_method, do_nothing_method)
    }
  end

  def test_write_python_app_yaml
    assert_nothing_raised(SystemExit) {
      Generator.write_python_app_yaml_file("boo", "/tmp/boo", GeneratorFakeFile)
    }
  end

  def test_write_python_main_py
    assert_nothing_raised(SystemExit) {
      Generator.write_python_cicero_code("def boo():\n  print 'hello world!'",
        "boo", "/tmp/boo", GeneratorFakeFile)
    }
  end

  def test_write_go_app_yaml
    assert_nothing_raised(SystemExit) {
      Generator.write_go_app_yaml_file("boo", "/tmp/boo", GeneratorFakeFile)
    }
  end

  def test_write_go_main_go
    assert_nothing_raised(SystemExit) {
      Generator.write_go_cicero_code("func Boo() string { return \"2\" }",
        "boo", "/tmp/boo", GeneratorFakeFile)
    }
  end
end
