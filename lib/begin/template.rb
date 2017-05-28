require 'begin/config'
require 'begin/output'
require 'begin/path'
require 'fileutils'
require 'mustache'
require 'rugged'
require 'uri'

module Begin
  # Represents an installed template on the user's machine.
  class Template
    CONFIG_NAME = '.begin.yml'.freeze

    def initialize(path)
      @path = path
      @path.ensure_dir_exists
    end

    def uninstall
      # Must be implemented in base class
      raise NotImplementedError
    end

    def update
      # Must be implemented in base class
      raise NotImplementedError
    end

    def config_path
      Path.new CONFIG_NAME, @path, 'Config'
    end

    def config
      Config.from_file config_path
    end

    def run(target_dir, context)
      target_dir = Path.new target_dir, '.', 'Directory'
      target_dir.ensure_dir_exists
      paths = process_path_names @path, target_dir, context
      process_files paths, context
    end

    def ensure_no_back_references(source_path, expanded_path, target_dir)
      return if target_dir.contains? expanded_path
      err = 'Backward-reference detected in expanded ' \
            "template path. Details to follow.\n"
      err += "Source Path:     #{source_path}\n"
      err += "Expanded Path:   #{expanded_path}\n"
      err += "Expected Parent: #{target_dir}\n"
      raise err
    end

    def ensure_no_conflicts(paths, source_path, target_path)
      return unless paths.key? target_path
      err = "Conflicting templates detected. Details to follow.\n"
      err += "(1) Source File: #{source_path}\n"
      err += "(1) ..Writes To: #{target_path}\n"
      err += "(2) Source File: #{paths[target_path]}\n"
      err += "(2) ..Writes To: #{target_path}\n"
      raise err
    end

    def process_path_name(source_path, target_dir, context)
      expanded_name = Mustache.render source_path.basename, context
      expanded_path = Path.new expanded_name, target_dir, 'Target'
      ensure_no_back_references source_path, expanded_path, target_dir
      expanded_path
    end

    def process_path_names_in_dir(source, target, paths, working_set, context)
      Dir.glob(File.join([source, '*'])).each do |entry|
        source_path = Path.new entry, '.', 'Source'
        target_path = process_path_name source_path, target, context
        ensure_no_conflicts paths, source_path, target_path
        paths[target_path] = source_path
        working_set.push [source_path, target_path] if source_path.directory?
      end
    end

    def process_path_names(source_dir, target_dir, context)
      paths = {}
      working_set = [[source_dir, target_dir]]
      until working_set.empty?
        source, target = working_set.pop
        process_path_names_in_dir source, target, paths, working_set, context
      end
      paths
    end

    def process_file(source_path, target_path, context)
      file = File.open source_path, 'rb'
      contents = file.read
      out = File.open target_path, 'wb'
      out.write Mustache.render(contents, context)
    end

    def process_files(paths, context)
      paths.each do |target, source|
        target.make_parent_dirs
        if source.directory?
          target.make_dir
        else
          process_file source, target, context
        end
      end
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

    def update
      # Do nothing. Symlink templates are always up-to-date.
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

    def check_repository
      if @repository.head_unborn?
        raise "HEAD is unborn in local repository. Please fix: #{@path}"
      end
      return unless @repository.head_detached?
      raise "HEAD is detached in local repository. Please fix: #{@path}"
    end

    def local_branch
      ref = @repository.head
      raise "HEAD is not a branch. Please fix: #{@path}" unless ref.branch?
      branch = @repository.branches[ref.name]
      return branch if branch
      raise "Could not find branch '#{ref.name}' in local repository: #{@path}"
    end

    def upstream_branch(branch)
      upstream = branch.upstream
      return upstream if upstream
      raise "Local branch '#{branch.name}' does not track an upstream " \
            "branch in local repository: #{@path}"
    end

    def fast_forward(from_branch, to_branch)
      upstream_commit = to_branch.target
      analysis = @repository.merge_analysis(upstream_commit)
      unless analysis.include? :fastforward
        raise "Cannot fast-forward local branch '#{from_branch.name}' " \
              "to match upstream branch '#{to_branch.name}' " \
              "in local repository: #{@path}"
      end
      @repository.reset to_branch.target, :hard
    end

    def update
      check_repository
      branch = local_branch
      upstream = upstream_branch local_branch
      upstream.remote.fetch
      return if branch.upstream.target == branch.target
      fast_forward(branch, upstream)
    end
  end
end
