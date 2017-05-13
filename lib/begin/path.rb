module Begin
  # The canonical file path representation used throughout the application.
  # Paths are immediately expanded into absolute file paths on construction
  class Path
    def initialize(path, parent_dir, help)
      @path = File.expand_path path, parent_dir
      @help = help
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

    def ensure_dir_is_empty
      ensure_dir_exists
      return if Dir.glob(File.join([path, '*'])).empty?
      raise IOError, "#{@help} '#{@path}' is not empty"
    end

    def make_dir
      unless File.exist? @path
        Begin::Output.action "Making #{@help} '#{@path}'"
        Dir.mkdir @path
      end
      ensure_dir_exists
    end

    def copy_to(destination)
      ensure_exists
      destination.ensure_dir_exists
      Begin::Output.action "Making #{@help} '#{@path}'"
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
  end
end
