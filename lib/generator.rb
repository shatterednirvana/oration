# Programmer: Chris Bunch

require 'fileutils'


# A list of languages that we can build Cicero-ready applications for. Right
# now it's just Python and Go.
# TODO(cgb): Add Java support
SUPPORTED_LANGUAGES = %w{py go}


module Generator

  # This function finds out what language the application we need to make
  # 'Cicero-ready' is, and if it is a supported language, dispatches the
  # necessary function to do so. See SUPPORTED_LANGUAGES for the currently
  # supported languages.
  def self.generate_app(main_file,
      function_name,
      output_dir,
      app_id,
      generate_python_app=Generator.method(:generate_python_app),
      generate_go_app=Generator.method(:generate_go_app))

    file_suffix = main_file.scan(/\.(.*)\Z/).flatten.to_s

    if file_suffix.empty?  # no suffix
      abort("The file specified needs an extension.")
    end

    if !SUPPORTED_LANGUAGES.include?(file_suffix)
      abort("The file specified is not in a supported language. Supported " +
        "languages are #{SUPPORTED_LANGUAGES.join(', ')}")
    end

    case file_suffix
    when "py"
      generate_python_app.call(main_file, function_name, output_dir, app_id)
    when "go"
      generate_go_app.call(main_file, function_name, output_dir, app_id)
    end
  end

  # This method generates a Python Google App Engine application containing
  # the function that the user specified. This requires us to search their
  # code for the actual function, make a directory for their app, write
  # an app.yaml for the app, and a Python file containing our Cicero
  # interface and their function.
  def self.generate_python_app(main_file, function_name, output_dir, app_id,
    make_directory=FileUtils.method(:mkdir_p),
    write_python_app_yaml=Generator.method(:write_python_app_yaml_file),
    write_python_cicero_code=Generator.method(:write_python_cicero_code),
    copy_app_files=Generator.method(:copy_app_files))

    make_directory.call(output_dir)
    write_python_app_yaml.call(app_id, output_dir)
    write_python_cicero_code.call(main_file, function_name, output_dir)
    copy_app_files.call(main_file, output_dir)
  end

  # This method generates a Go Google App Engine application containing
  # the function that the user specified.
  def self.generate_go_app(main_file, function_name, output_dir, app_id,
    make_directory=FileUtils.method(:mkdir_p),
    write_go_app_yaml=Generator.method(:write_go_app_yaml_file),
    write_go_cicero_code=Generator.method(:write_go_cicero_code),
    copy_app_files=Generator.method(:copy_app_files))

    make_directory.call(output_dir)
    go_code_folder = output_dir + File::Separator + function_name
    make_directory.call(go_code_folder)

    write_go_app_yaml.call(app_id, output_dir)
    write_go_cicero_code.call(main_file, function_name, go_code_folder)
    copy_app_files.call(main_file, go_code_folder)
  end

  # Writes an app.yaml file for use with Python Google App Engine applications.
  # TODO(cgb): Add support for jquery and bootstrap? If so, also be sure to
  # write those files in the given directory.
  def self.write_python_app_yaml_file(app_id, output_dir, file=File)
    app_yaml_contents = <<YAML
application: #{app_id}
version: 1
runtime: python
api_version: 1

handlers:
- url: .*
  script: main.py
YAML

    app_yaml_location = file.expand_path(output_dir + File::Separator +
      "app.yaml")

    file.open(app_yaml_location, "w+") { |file| file.write(app_yaml_contents) }
  end

  # Writes a main.py file for use with Python Google App Engine applications.
  # Sets up a standard set of routes according to the Cicero API.
  # TODO(cgb): The user may have their own imports in the code - consider
  # automatically placing them in as well.
  def self.write_python_cicero_code(file_name, function_name, output_dir,
    file=File)

    package_name = File.basename(file_name, ".py")
    template_location = File.join(File.dirname(__FILE__), "..",
      "templates", "main.py")
    main_py_contents = file.open(template_location) { |f| f.read }
    main_py_contents.gsub!(/CICERO_PACKAGE_NAME/, package_name)
    main_py_contents.gsub!(/CICERO_FUNCTION_NAME/, function_name)

    invokable_name = package_name + "." + function_name
    main_py_contents.gsub!(/CICERO_PACKAGE_AND_FUNCTION_NAME/, invokable_name)

    main_py_location = file.expand_path(output_dir + File::Separator +
      "main.py")

    file.open(main_py_location, "w+") { |file| file.write(main_py_contents) }
  end

  # Writes an app.yaml file for use with Go Google App Engine applications.
  # Right now, we direct all URL requests to the Go app we are about to
  # construct, but in the future we may add support for jQuery and Bootstrap
  # to automatically put a nice UI on the / url.
  def self.write_go_app_yaml_file(app_id, output_dir, file=File)
    app_yaml_contents = <<YAML
application: #{app_id.downcase}
version: 1
runtime: go
api_version: 3

handlers:
- url: /.*
  script: _go_app
YAML

    app_yaml_location = file.expand_path(output_dir + File::Separator +
      "app.yaml")

    file.open(app_yaml_location, "w+") { |file| file.write(app_yaml_contents) }
  end

  # Writes a main.go function that is a Go Google App Engine application with
  # the user's function in it.
  def self.write_go_cicero_code(file_name, function_name, output_dir, file=File)
    package_name = File.basename(file_name, ".go")
    template_location = File.join(File.dirname(__FILE__), "..",
      "templates", "main.go")
    main_go_contents = file.open(template_location) { |f| f.read }
    main_go_contents.gsub!(/CICERO_FUNCTION_NAME/, function_name)
    main_go_contents.gsub!(/CICERO_PKG_NAME/, package_name)

    invokable_name = package_name + "." + function_name
    main_go_contents.gsub!(/CICERO_PACKAGE_AND_FUNCTION_NAME/, invokable_name)
    main_go_location = file.expand_path(output_dir + File::Separator +
      "main.go")

    file.open(main_go_location, "w+") { |file| file.write(main_go_contents) }
  end

  # Copies over any files in the directory the user has given us over to the
  # new directory we are making for their App Engine app.
  def self.copy_app_files(main_file, output_dir, fileutils=FileUtils)
    source_dir = File.dirname(main_file) + "/."
    FileUtils.cp_r(source_dir, output_dir)
  end
end
