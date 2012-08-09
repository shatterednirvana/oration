require 'oration/generator'
require 'mixlib/cli'

module Oration
  class CLI
    include Mixlib::CLI

    banner <<EOF
Usage: oration [OPTION]...
Generate a cloud app that executes your code according to the Cicero API.
Everything under the directory of FILE will be included in the app.

EOF

    option :file, short: "-f FILE", long: "--file=FILE",
      required: true, description: "look for function in FILE"
    option :function, short: "-n FUNCTION", long: "--function=FUNCTION",
      required: true, description: "execute FUNCTION in the app"
    option :cloud, short: "-c CLOUD", long: "--cloud=CLOUD",
      required: true, description: "make an app for specified cloud service
                                     [azure, appengine]"
    option :help, short: "-h", long: "--help", boolean: true,
      description: "display this help and exit", on: :tail,
      show_options: true, exit: 0

    def run!
      parse_options
      generator = Generator.new config
      generator.run!
    end
  end
end

