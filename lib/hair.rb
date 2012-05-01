require 'mustache'

class Hair
  class << self
    # Render all the templates in the directory `source` using the given
    # context and put the results in the directory `target`.
    def render(source, target, ctx = {})
      target = File.expand_path(target)
      p source, target, ctx

      Dir.chdir(source) do
        p Dir['**/*']
        Dir['**/*'].each do |name|
          next if File.directory?(name)
          rendered = Mustache.render(File.read(name), ctx)

          target_file = File.join(target, name)
          FileUtils.mkdir_p(File.dirname(target_file))
          File.open(target_file, 'w') {|f| f.write(rendered)}
        end
      end
    end
  end
end
