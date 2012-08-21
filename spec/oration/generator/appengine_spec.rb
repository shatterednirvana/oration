module Oration
  describe Generator do
    describe "-- a generated app for AppEngine", :data => true do

      context "in Python" do
        before(:each) do
          @generator = Generator.new generator_options(
            @data, "appengine", "py")
          @generator.run!
        end

        # start and stop AppEngine app
        let(:port) { "8000" }
        before(:each) do
          Dir.chdir @generator.output_directory do
            @app = IO.popen(
              "dev_appserver.py --skip_sdk_update_check --port=#{port} .")
          end
          sleep 10
        end
        after(:each) { kill_process @app.pid }

        include_examples "Cicero API"
      end

      context "in Java" do
        before(:each) do
          @generator = Generator.new generator_options(
            @data, "appengine", "java")
          @generator.run!
        end

        # start and stop AppEngine app using Maven
        let(:port) { "8080" }
        before(:each) do
          Dir.chdir @generator.output_directory do
            if not system "mvn gae:unpack"
              throw "could not download Java AppEngine SDK"
            end
            @app = IO.popen("mvn gae:run 1>&2")
          end
          sleep 20
        end
        after(:each) do
          Dir.chdir @generator.output_directory do
            if not system "mvn gae:stop"
              throw "could not stop app"
            end
          end
          kill_process @app.pid
        end

        include_examples "Cicero API"
      end
    end
  end
end
