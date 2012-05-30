require 'mustache'
require 'ptools'

class Hair
  class << self
    # Render all the templates in the directory `source` using the given
    # context and put the results in the directory `target`.
    #
    # Copy binary files as-is.
    def render(source, target, ctx = {})
      target = File.expand_path(target)

      Dir.chdir(source) do
        Dir['**/*'].each do |name|
          next if File.directory?(name)
          target_dir = File.join(target, File.dirname(name))
          FileUtils.mkdir_p(target_dir)

          if File.binary? name
            FileUtils.cp name, target_dir
          else
            rendered = Mustache.render(File.read(name), ctx)
            target_file = File.join(target, name)
            File.open(target_file, 'w') {|f| f.write(rendered)}
          end
        end
      end
    end
  end
end
