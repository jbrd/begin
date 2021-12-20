module Begin
  # The canonical file path representation used throughout the application.
  # Paths are immediately expanded into absolute file paths on construction
  class Path
    def initialize(path, parent_dir, help)
      @path = File.expand_path path, parent_dir
      @help = help
    end

    def eql?(other)
      @path.eql?(other.to_str)
    end

    def hash
      @path.hash
    end

    def to_s
      @path
    end

    def to_str
      @path
    end

    def ensure_exists
      return if File.exist? @path

      raise IOError, "#{@help} '#{@path}' does not exist"
    end

    def ensure_symlink_exists
      ensure_exists
      return if File.symlink? @path

      raise IOError, "#{@help} '#{@path}' is not a symbolic link"
    end

    def ensure_dir_exists
      ensure_exists
      return if directory?

      raise IOError, "#{@help} '#{@path}' is not a directory"
    end

    def dir_contents
      escaped_path = @path.gsub(/[\\\{\}\[\]\*\?\.]/) { |x| '\\' + x }
      Dir.glob(File.join([escaped_path, '*']))
    end

    def make_dir
      Dir.mkdir @path unless File.exist? @path
      ensure_dir_exists
    end

    def make_parent_dirs
      parent = File.dirname @path
      FileUtils.mkdir_p parent
    end

    def copy_to(destination)
      ensure_exists
      destination.ensure_dir_exists
      FileUtils.cp @path, destination
    end

    def basename
      File.basename @path
    end

    def directory?
      File.directory? @path
    end

    def exists?
      File.exist? @path
    end

    def contains?(path)
      path.to_str.start_with? @path
    end
  end
end
