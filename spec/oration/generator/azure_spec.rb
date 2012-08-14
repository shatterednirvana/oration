
shared_context "start and stop Python app" do |name, path|
  let(:port) { "8000" }
  before(:each) do
    Dir.chdir File.join(@generator.output_directory, File.dirname(path)) do
      ENV['PORT'] = port
      instance_variable_set "@#{name}", IO.popen("python \"#{File.basename(path)}\"")
      ENV['PORT'] = ""
    end
    sleep 1
  end
  after(:each) { kill_process instance_variable_get("@#{name}").pid }
end

shared_context "start and stop Java app" do |name, path, class_name|
  let(:port) { "8000" }
  before(:each) do
    Dir.chdir File.join(@generator.output_directory, path) do
      throw "could not package Java app #{name.to_s}" if not system "mvn package"
      ENV['PORT'] = port
      if Config::CONFIG['host_os'] =~ /mswin/
        instance_variable_set "@#{name}", IO.popen('java -cp target\\classes;"target\\dependency\\*" ' + class_name)
      else
        instance_variable_set "@#{name}", IO.popen('java -cp target/classes:"target/dependency/*" ' + class_name)
      end
      ENV['PORT'] = ""
    end
    sleep 1
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

module Oration
  describe Generator do
    describe "-- a generated app for Azure", :data => true do

      context "in Python" do
        context "using local storage", :require_windows => true do
          before(:each) do
            @generator = Generator.new generator_options(@data, "azure", "py")
            @generator.run!
          end

          include_context "start and stop Azure Storage Emulator"
          include_context "start and stop Python app", :main, "WorkerRole/app/main.py"
          include_context "start and stop Python app", :bg, "WorkerRole/app/backgroundworker.py"

          include_examples "Cicero API"
        end
        context "using Azure storage", :require_azure_credentials => true do
          before(:each) do
            @generator = Generator.new generator_options(@data, "azure", "py")
            @generator.run!
          end

          include_context "start and stop Python app", :main, "WorkerRole/app/main.py"
          include_context "start and stop Python app", :bg, "WorkerRole/app/backgroundworker.py"

          include_examples "Cicero API"
        end
      end

      context "in Java" do
        context "using local storage", :require_windows => true do
          before(:each) do
            @generator = Generator.new generator_options(@data, "azure", "java")
            @generator.run!
          end

          include_context "start and stop Azure Storage Emulator"
          include_context "start and stop Python app", :main, "WorkerRole/app/main.py"
          include_context "start and stop Java app", :bg, "WorkerRole/backgroundworker/", "BackgroundWorker"

          include_examples "Cicero API"
        end
        context "using Azure storage", :require_azure_credentials => true do
          before(:each) do
            @generator = Generator.new generator_options(@data, "azure", "java")
            @generator.run!
          end

          include_context "start and stop Python app", :main, "WorkerRole/app/main.py"
          include_context "start and stop Java app", :bg, "WorkerRole/backgroundworker/", "BackgroundWorker"

          include_examples "Cicero API"
        end
      end

    end
  end
end

