require 'spec_helper'
require 'oration/generator'

require 'rest_client'
require 'json'
require 'rbconfig'

def kill_process(pid)
  begin
    Process.getpgid pid
  rescue Errno::ESRCH
    raise "application failed"
  end

  Process.kill "KILL", pid
  Process.wait pid

  begin
    Process.getpgid pid
    raise "application did not exit"
  rescue Errno::ESRCH
  end
end

def generator_options(data, cloud, language)
  case language
  when "py"
    { :file => "#{data}/get-random-number-python/get_random_number.py",
      :function => "get_random_number", :cloud => cloud }
  when "java"
    { :file => "#{data}/get-random-number-java/GetRandomNumber.java",
      :function => "getRandomNumber", :cloud => cloud }
  when "go"
    { :file => "#{data}/get-random-number-go/get_random_number.go",
      :function => "GetRandomNumber", :cloud => cloud }
  else
    raise "unsupported language #{language}"
  end
end

shared_examples "Cicero API" do
  let(:host) { "http://localhost:#{port}" }
  it "responds to GET /" do RestClient::get "#{host}/" end
  it "responds to post, get status and get output of task" do
    task = JSON.parse RestClient::post("#{host}/task?f=#{@generator.function}", "")
    raise "starting a task failed" unless task["result"] == "success"

    loop do
      status = JSON.parse RestClient::get("#{host}/task?id=#{task['id']}")
      case status["result"]
      when "success"
        case status["status"]
        when "started" then sleep 2
        when "finished" then break
        else
          raise "task status unknown: '#{status['status']}', in #{status.inspect}"
        end
      else
        sleep 2
      end
    end

    data = JSON.parse RestClient.get("#{host}/data?location=#{task['output_location']}")
    raise "getting output data failed" unless data["result"] == "success"
  end
end

module Oration
  describe Generator do

    context "when automatically generating an app name" do
      it "includes the file and function name in the app name" do
        g = Generator.new :file => "path/to/short.py",
          :function => "name", :cloud => "azure"
        g.application_name.should include("shortname")
      end
      it "truncates the app name at 20 characters, 15 from file and function names" do
        g = Generator.new :file => "path/longdirectoryname/longfilename.py",
          :function => "longfunctionname", :cloud => "azure"
        g.application_name.length.should <= 20
        g.application_name.should include("longfilenamelong") # 15 chars
      end
      it "removes special characters from the app name" do
        g = Generator.new :file => "some-special/char_ACTERS.py",
          :function => "name", :cloud => "azure"
        g.application_name.should =~ /[a-z0-9]/
      end
      it "creates a unique application name each time" do
        a = Generator.new :file => "a.py", :function => "name", :cloud => "azure"
        b = Generator.new :file => "a.py", :function => "name", :cloud => "azure"
        a.application_name.should_not == b.application_name
      end
    end

    context "when validating its arguments" do
      it "doesn't support C files in AppEngine" do
        g = Generator.new :file => "boo.c", :function => "blarg", :cloud => "appengine"
        expect { g.validate_arguments }.to raise_error
      end
      it "doesn't support files without an extension" do
        g = Generator.new :file => "boo", :function => "blarg", :cloud => "appengine"
        expect { g.validate_arguments }.to raise_error
      end
      it "supports Python files in AppEngine" do
        g = Generator.new :file => "boo.py", :function => "blarg", :cloud => "appengine"
        expect { g.validate_arguments }.to_not raise_error
      end
      it "doesn't support C files in Azure" do
        g = Generator.new :file => "boo.c", :function => "blarg", :cloud => "azure"
        expect { g.validate_arguments }.to raise_error
      end
      it "supports Python files in Azure" do
        g = Generator.new :file => "boo.py", :function => "blarg", :cloud => "azure"
        expect { g.validate_arguments }.to_not raise_error
      end
      # The rest are not tested because if these work, then they
      # ovbiously work properly. See `Generator.supported_clouds`.
    end

    context "when validating the user's code", :data => true do
      it "fails fast when the file doesn't exist" do
        g = Generator.new :file => "#{@data}/good-directory/bad_file.py", :function => "blarg", :cloud => "azure"
        expect { g.validate_code }.to raise_error
      end
      it "fails fast when the function doesn't exist" do
        g = Generator.new :file => "#{@data}/good-directory/good_file.py", :function => "bad_function", :cloud => "azure"
        expect { g.validate_code }.to raise_error
      end
      it "succeeds when the file and function do exist" do
        g = Generator.new :file => "#{@data}/good-directory/good_file.py", :function => "good_function", :cloud => "azure"
        expect { g.validate_code }.not_to raise_error
      end
    end

    it "generates an output directory ending with the cloud name" do
      a = Generator.new :file => "some/path/file.py", :function => "blarg", :cloud => "appengine"
      File.expand_path(a.output_directory).should == File.expand_path("some/path-appengine")
      b = Generator.new :file => "some/path/file.py", :function => "blarg", :cloud => "azure"
      File.expand_path(b.output_directory).should == File.expand_path("some/path-azure")
    end
    it "generates an output directory properly when the file is in working dir" do
      Dir.chdir "spec/data" do
        g = Generator.new :file => "somefile.py", :function => "blarg", :cloud => "azure"
        File.expand_path(g.output_directory).should == File.expand_path("../data-azure")
      end
    end

    it "fails fast when the output directory already exists", :data => true do
      Dir.mkdir "#{@data}/good-directory-azure"
      g = Generator.new :file => "#{@data}/good-directory/somefile.py", :function => "blarg", :cloud => "azure"
      expect { g.validate_output }.to raise_error
    end


    it "generates apps for each supported language and cloud without failure", :data => true do
      Generator.supported_clouds.each do |cloud, languages|
        languages.each do |language|
          g = Generator.new generator_options(@data, cloud.to_s, language)
          expect { g.run! }.to_not raise_error
        end
      end
    end

  end
end

