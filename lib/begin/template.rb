require 'begin/output'
require 'begin/path'
require 'fileutils'
require 'rugged'
require 'uri'

module Begin
  # Represents an installed template on the user's machine.
  class Template
    def initialize(path)
      @path = path
      @path.ensure_dir_exists
    end

    def uninstall
      raise NotImplementedError
    end
  end

  # Encapsulates the logic for templates that are installed as symlinks
  # on the user's machine.
  class SymlinkTemplate < Template
    def initialize(path)
      super path
      @path.ensure_symlink_exists
    end

    def uninstall
      File.unlink @path
    end
  end

  # Encapsulates the logic for templates that are installed as cloned
  # git repositories on the user's machine.
  class GitTemplate < Template
    def initialize(path)
      super path
      @repository = Rugged::Repository.new path.to_s()
    end

    def uninstall
     FileUtils.rm_rf @path
    end
  end
end
