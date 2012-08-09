require 'spec_helper'
require 'oration/generator'

require 'rest_client'
require 'json'

def kill_process(pid)
  Process.kill "KILL", pid
  Process.wait pid
  raise "application did not exit" if not $?.exited?
  raise "application failed" if not $?.success?
end

def generator_options(data, cloud, language)
  case language
  when "py"
    { file: "#{data}/get-random-number-python/get_random_number.py",
      function: "get_random_number", cloud: cloud }
  when "java"
    { file: "#{data}/get-random-number-java/GetRandomNumber.java",
      function: "getRandomNumber", cloud: cloud }
  when "go"
    { file: "#{data}/get-random-number-go/get_random_number.go",
      function: "GetRandomNumber", cloud: cloud }
  else
    raise "unsupported language #{language}"
  end
end

shared_context "start and stop Python app" do |name, path|
  let(:port) { "8000" }
  before(:each) do
    Dir.chdir File.join(@generator.output_directory, File.dirname(path)) do
      instance_variable_set "@#{name}", IO.popen([{"PORT" => port}, "python", File.basename(path)])
    end
  end
  after(:each) { kill_process instance_variable_get("@#{name}").pid }
end

shared_context "start and stop Azure Storage Emulator" do
  before(:all) do
    if not system "C:/Program Files/Windows Azure Emulator/emulator/csrun.exe", "/devstore:start"
      raise "could not start Azure Storage Emulator"
    end
  end
  #after(:all) do
    #if not system "C:/Program Files/Windows Azure Emulator/emulator/csrun.exe", "/devstore:shutdown"
      #raise "could not stop Azure Storage Emulator"
    #end
  #end
end

shared_examples "Cicero API" do
  let(:host) { "http://localhost:#{port}" }
  it "responds to GET /" do RestClient::get "#{host}/" end
  it "responds to post, get status and get output of task" do
    task = JSON.parse RestClient::post("#{host}/task?f=#{@generator.function}", nil)
    raise "starting a task failed" unless task["result"] == "success"

    loop do
      status = JSON.parse RestClient::get("#{host}/task?id=#{task['id']}")
      case status["result"]
      when "success"
        case status["status"]
        when "started" then sleep 2
        when "finished" then break
        else
          raise "task status unknown: '#{status['status']}', in #{status}"
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

    before(:each, data: true) { @data = get_test_data }
    after(:each, data: true) { FileUtils.rm_r @data }

    context "when automatically generating an app name" do
      it "includes the file and function name in the app name" do
        g = Generator.new file: "path/to/short.py",
          function: "name", cloud: "azure"
        g.application_name.should include("shortname")
      end
      it "truncates the app name at 20 characters, 15 from file and function names" do
        g = Generator.new file: "path/longdirectoryname/longfilename.py",
          function: "longfunctionname", cloud: "azure"
        g.application_name.length.should <= 20
        g.application_name.should include("longfilenamelong") # 15 chars
      end
      it "removes special characters from the app name" do
        g = Generator.new file: "some-special/char_ACTERS.py",
          function: "name", cloud: "azure"
        g.application_name.should =~ /[a-z0-9]/
      end
      it "creates a unique application name each time" do
        a = Generator.new file: "a.py", function: "name", cloud: "azure"
        b = Generator.new file: "a.py", function: "name", cloud: "azure"
        a.application_name.should_not == b.application_name
      end
    end

    context "when validating its arguments" do
      it "doesn't support C files in AppEngine" do
        g = Generator.new file: "boo.c", function: "blarg", cloud: "appengine"
        expect { g.validate }.to raise_error
      end
      it "doesn't support files without an extension" do
        g = Generator.new file: "boo", function: "blarg", cloud: "appengine"
        expect { g.validate }.to raise_error
      end
      it "supports Python files in AppEngine" do
        g = Generator.new file: "boo.py", function: "blarg", cloud: "appengine"
        expect { g.validate }.to_not raise_error
      end
      it "doesn't support C files in Azure" do
        g = Generator.new file: "boo.c", function: "blarg", cloud: "azure"
        expect { g.validate }.to raise_error
      end
      it "supports Python files in Azure" do
        g = Generator.new file: "boo.py", function: "blarg", cloud: "azure"
        expect { g.validate }.to_not raise_error
      end
      # The rest are not tested because if these work, then they
      # ovbiously work properly. See `Generator.supported_clouds`.
    end

    it "generates apps for each supported language and cloud without failure", data: true do
      Generator.supported_clouds.each do |cloud, languages|
        languages.each do |language|
          g = Generator.new generator_options(@data, cloud.to_s, language)
          expect { g.run! }.to_not raise_error
        end
      end
    end

    it "should pass the old test suite"

    describe "-- a generated app", data: true do

      context "in Python" do
        context "for Azure" do
          before(:each) do
            @generator = Generator.new generator_options(@data, "azure", "py")
            @generator.run!
          end

          include_context "start and stop Azure Storage Emulator"
          include_context "start and stop Python app", :main, "WorkerRole/app/main.py"
          include_context "start and stop Python app", :bg, "WorkerRole/app/backgroundworker.py"

          include_examples "Cicero API"
        end
      end
    end

  end
end

