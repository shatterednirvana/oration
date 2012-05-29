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
    description "An identifier to be used for this app (in AppEngine, it's the appid)."
  end

  flag "cloud" do
    description "The cloud to which this app will be deployed (appengine, azure)."
  end
end


# This method takes in the arguments given to oration and validates them.
# Right now it's just three arguments: the name of the main code file to
# exec, the name of the function in that file that should be exec'd, and
# where we should write their App Engine app.
# We validate that the file specified exists and has a function
# with that name, and that the directory they specified doesn't exist (so
# that we don't overwrite anything already there).
def validate_arguments(main_file, function_name, output_dir, app_id, cloud)
  if !File.exists?(main_file)
    abort("#{main_file} didn't exist.")
  end

  contents = File.open(main_file) { |f| f.read }

  # Right now we support Python and Go code, so match against method
  # signatures in those languages.
  python_sig = /def #{function_name}\(/
  go_method_sig = /func #{function_name}\(/
  java_method_sig = /public static .+ #{function_name}\(/
  all_languages_method_sig_regex = /#{python_sig}|#{go_method_sig}|#{java_method_sig}/
  puts all_languages_method_sig_regex.to_s

  if !contents.match(all_languages_method_sig_regex)
    abort("We couldn't find the function #{function_name} in the file " +
      "#{main_file}")
  end

  if File.exists?(output_dir)
    abort("The output location specified, #{output_dir}, already exists." +
      " Please remove it and try again.")
  end

  case cloud
  when 'appengine', 'azure'
  else
    abort("The cloud specified, #{cloud}, is not supported. Only 'appengine' and 'azure' are supported")
  end
end


def oration
  OrationFlags.and_process!

  validate_arguments(ARGV.flags.file, ARGV.flags.function, ARGV.flags.output, 
    ARGV.flags.appid, ARGV.flags.cloud)
  Generator.generate_app(File.expand_path(ARGV.flags.file), ARGV.flags.function, 
    ARGV.flags.output, ARGV.flags.appid, ARGV.flags.cloud)
  puts "Done! Your application can be found at #{ARGV.flags.output}"
end
