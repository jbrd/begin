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

    def self.install(source_uri, path)
      source_path = Path.new source_uri, '.', 'Source path'
      source_path.ensure_dir_exists
      begin
        File.symlink source_path, path
        Output.success "Created symbolic link to '#{source_path}'"
      rescue NotImplementedError
        raise NotImplementedError, 'TODO: Copy tree when symlinks not supported'
      end
      SymlinkTemplate.new path
    end

    def uninstall
      File.unlink @path
    end
  end

  # Encapsulates the logic for templates that are installed as cloned
  # git repositories on the user's machine.
  class GitTemplate < Template
    def initialize(path)
      super path
      @repository = Rugged::Repository.new path.to_s
    end

    def self.install(source_uri, path)
      Rugged::Repository.clone_at source_uri, path.to_s
      Output.success 'Template source was successfully git cloned'
      GitTemplate.new path
    end

    def uninstall
      FileUtils.rm_rf @path
    end
  end
end
