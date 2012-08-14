shared_context "start and stop AppEngine app" do |name|
  let(:port) { "8000" }
  before(:each) do
    Dir.chdir @generator.output_directory do
      instance_variable_set "@#{name}", IO.popen(
        "dev_appserver.py --skip_sdk_update_check --port=#{port} .")
    end
    sleep 10
  end
  after(:each) { kill_process instance_variable_get("@#{name}").pid }
end

module Oration
  describe Generator do
    describe "-- a generated app for AppEngine", :data => true do

      context "in Python" do
        before(:each) do
          @generator = Generator.new generator_options(@data, "appengine", "py")
          @generator.run!
        end

        include_context "start and stop AppEngine app", :main
        include_examples "Cicero API"
      end

      context "in Java" do
        it "works"
      end
    end
  end
end
