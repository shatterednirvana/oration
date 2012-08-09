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

shared_context "start and stop Python app" do |name, path|
  let(:port) { "8000" }
  before(:each) do
    Dir.chdir File.join(generator.output_directory, File.dirname(path)) do
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
    task = JSON.parse RestClient::post("#{host}/task?f=#{generator.function}", nil)
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

    context "when automatically generating an app name" do
      it "includes the file and function name in the app name" do
        g = Oration::Generator.new file: "path/to/short.py",
          function: "name", cloud: "azure"
        g.application_name.should include("shortname")
      end
      it "truncates the app name at 20 characters, 15 from file and function names" do
        g = Oration::Generator.new file: "path/longdirectoryname/longfilename.py",
          function: "longfunctionname", cloud: "azure"
        g.application_name.length.should <= 20
        g.application_name.should include("longfilenamelong") # 15 chars
      end
      it "removes special characters from the app name" do
        g = Oration::Generator.new file: "some-special/char_ACTERS.py",
          function: "name", cloud: "azure"
        g.application_name.should =~ /[a-z0-9]/
      end
      it "creates a unique application name each time" do
        a = Oration::Generator.new file: "a.py", function: "name", cloud: "azure"
        b = Oration::Generator.new file: "a.py", function: "name", cloud: "azure"
        a.application_name.should_not == b.application_name

        [0..5].each { |x| puts x }
      end
    end

    it "should pass the old test suite"

    context "when generating apps" do
      before(:each) { @data = get_test_data }
      after(:each) { FileUtils.rm_r @data }

      context "in Python" do
        context "for Azure" do
          let(:generator) do
            Generator.new \
              file: "#{@data}/get-random-number-python/get_random_number.py",
              function: "get_random_number", cloud: "azure"
          end
          before(:each) { generator.run! }

          include_context "start and stop Azure Storage Emulator"
          include_context "start and stop Python app", :main, "WorkerRole/app/main.py"
          include_context "start and stop Python app", :bg, "WorkerRole/app/backgroundworker.py"

          include_examples "Cicero API"
        end
      end
    end

  end
end

