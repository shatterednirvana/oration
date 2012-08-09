require 'fileutils'
require 'hair'

module Oration
  class Generator
    # A hash from supported clouds to lists of supported languages.
    def self.supported_clouds
      {azure: ['py', 'java'],
      appengine: ['py', 'go']}
    end

    attr_accessor :file, :function, :cloud, :application_name_salt
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}".to_sym, value)
      end
      raise "file not supplied" if @file.nil?
      raise "function name not supplied" if @function.nil?
      raise "cloud not supplied" if @cloud.nil?
      @application_name_salt = rand(1e4).to_s
    end

    # Aliases from before refactoring.
    # TODO: Replace in templates, and callers.
    def file_name; file end
    def function_name; function end
    def output_dir; output_directory end
    def app_id; application_name end

    def application_name
      (
        #File.basename(File.dirname(file)) +
        File.basename(file, language) + function
      ).gsub(/[^a-zA-Z0-9]/, '')[0...16].downcase + application_name_salt
    end
    def input_directory
      File.dirname(file)
    end
    def output_directory
      input_directory + "-azure"
    end

    # The language of the file to cloudify, as a file suffix.
    def language
      parts = file.split('.')
      raise "file has no extension" if parts.length < 2
      parts[-1]
    end

    # The namespace (full class/module name) in which the function is found.
    def namespace
      case language
      when 'py', 'go', 'java'
        File.basename(file, '.' + language)
      end
      # TODO: Add support for Java packages.
      #open(file) { |f| /^\s*package\s+(.*)\s*;$/.match(f.read)[1] }
    end

    def output_user_files_directory
      case cloud
      when 'azure'
        case language
        when 'py'
          File.join(output_directory, 'WorkerRole', 'app')
        when 'java'
          File.join(output_directory, 'WorkerRole', 'backgroundworker/src/main/java')
        else
          File.join(output_directory, 'WorkerRole', 'backgroundworker')
        end
      else
        output_directory
      end
    end

    def run!
      raise "file has empty extension" if language.empty?
      unless Oration::Generator.supported_clouds[cloud.to_sym].include?(language)
        raise "language not supported for cloud '#{cloud}'" 
      end

      # Create boilerplate code (cloud "harness"). Templates can call
      # instance methods.
      Hair.render(
        File.join(
          File.dirname(__FILE__), "..", "..", "templates", cloud, language),
        output_directory, self)

      # Move files with dynamic paths manually.
      case language
      when 'go'
        Dir.chdir(output_directory) do
          Dir.mkdir(function_name)
          FileUtils.mv('main.go', function_name)
        end
      end

      # Copy files in the directory where user's code is.
      copy_user_files_to output_user_files_directory
    end

    private
    def copy_user_files_to(target)
      FileUtils.cp_r(input_directory + "/.", target)
    end
  end
end

