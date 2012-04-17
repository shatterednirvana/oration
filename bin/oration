#!/usr/bin/env ruby

# Programmer: Chris Bunch

require 'rubygems'
require 'optiflag'

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
 require 'generator'

  
module OrationFlags extend OptiFlagSet
  flag "file" do
    description "The name of the file containing the function to execute."
  end

  flag "function" do
    description "The name of the function that should be remotely executed."
  end

  flag "output" do
    description "Where the newly constructed app should be written to."
  end

  flag "appid" do
    description "The Google App Engine appid that should be used for this app."
  end
end


# This method takes in the arguments given to oration and validates them.
# Right now it's just three arguments: the name of the main code file to
# exec, the name of the function in that file that should be exec'd, and
# where we should write their App Engine app.
# We validate that the file specified exists and has a function
# with that name, and that the directory they specified doesn't exist (so
# that we don't overwrite anything already there).
def validate_arguments(main_file, function_name, output_dir, app_id, file=File)
  if !file.exists?(main_file)
    abort("#{main_file} didn't exist.")
  end

  contents = file.open(main_file) { |f| f.read }

  # Right now we support Python and Go code, so match against method
  # signatures in those languages.
  python_sig = /def #{function_name}\(/
  go_method_sig = /func #{function_name}\(/
  all_languages_method_sig_regex = /#{python_sig}|#{go_method_sig}/

  if !contents.match(all_languages_method_sig_regex)
    abort("We couldn't find the function #{function_name} in the file " +
      "#{main_file}")
  end

  if file.exists?(output_dir)
    abort("The output location specified, #{output_dir}, already exists." +
      " Please remove it and try again.")
  end
end


# Normally we would just check if __FILE__ == $0, but this doesn't work if
# RubyGems is exec'ing this file, so instead just check if the thing we're
# executing ends in /bin/oration, the relative location of this file.
if $0.match(/\/bin\/oration\Z/)
  OrationFlags.and_process!

  validate_arguments(ARGV.flags.file, ARGV.flags.function, ARGV.flags.output, 
    ARGV.flags.appid)
  Generator.generate_app(ARGV.flags.file, ARGV.flags.function, 
    ARGV.flags.output, ARGV.flags.appid)
  puts "Done! Your application can be found at #{ARGV.flags.output}"
end
