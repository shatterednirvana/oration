require 'mustache'

class Hair
  # Render all the templates in the directory `source` using the given
  # context and put the results in the directory `target`.
  #
  # Copy binary files as-is.
  def self.render(source, target, ctx = {})
    target = File.expand_path(target)

    Dir.chdir(source) do
      Dir['**/*'].each do |name|
        next if File.directory?(name)
        target_dir = File.join(target, File.dirname(name))
        FileUtils.mkdir_p(target_dir)

        if binary? name
          FileUtils.cp name, target_dir
        else
          rendered = Mustache.render(File.read(name), ctx)
          target_file = File.join(target, name)
          File.open(target_file, 'w') {|f| f.write(rendered)}
        end
      end
    end
  end

  private
  # From ptools (https://github.com/djberg96/ptools/blob/master/lib/ptools.rb#L78)
  # which causes some kind of conflict with File.cp_r (try requiring at the top
  # of this file to see what I mean).
  #
  # Returns whether or not +file+ is a binary file. Note that this is
  # not guaranteed to be 100% accurate. It performs a "best guess" based
  # on a simple test of the first +File.blksize+ characters.
  #
  # Example:
  #
  # File.binary?('somefile.exe') # => true
  # File.binary?('somefile.txt') # => false
  #--
  # Based on code originally provided by Ryan Davis (which, in turn, is
  # based on Perl's -B switch).
  #
  def self.binary?(file)
    s = (File.read(file, File.stat(file).blksize) || "").split(//)
    ((s.size - s.grep(" ".."~").size) / s.size.to_f) > 0.30
  end
end
