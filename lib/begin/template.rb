# frozen_string_literal: true

require 'begin/config'
require 'begin/output'
require 'begin/path'
require 'fileutils'
require 'git'
require 'mustache'
require 'uri'

module Begin
  # Represents an installed template on the user's machine.
  class Template
    CONFIG_NAME = '.begin.yml'

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

      err = "File path collision detected. Details to follow.\n"
      err += "(1) Source File: #{source_path}\n"
      err += "(1) ..Writes To: #{target_path}\n"
      err += "(2) Source File: #{paths[target_path]}\n"
      err += "(2) ..Writes To: #{target_path}\n"
      raise err
    end

    def ensure_name_not_empty(source_path, expanded_name)
      return unless expanded_name.empty?

      err = "Mustache evaluation resulted in an empty file name...\n"
      err += "... whilst evaluating: #{source_path}"
      raise err
    end

    def process_path_name(source_path, target_dir, context)
      expanded_name = Mustache.render source_path.basename, context
      ensure_name_not_empty source_path, expanded_name
      expanded_path = Path.new expanded_name, target_dir, 'Target'
      ensure_no_back_references source_path, expanded_path, target_dir
      expanded_path
    end

    def process_path_names_in_dir(source, target, paths, working_set, context)
      source.dir_contents.each do |entry|
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
      contents = File.read source_path
      File.write target_path, Mustache.render(contents, context)
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
      @repository = Git.open(path.to_s)
    end

    def self.format_git_error_message(err)
      partition = err.message.partition('2>&1:')
      partition[2]
    end

    def self.install(source_uri, path)
      Git.clone(source_uri, path.to_s)
      Output.success 'Template source was successfully git cloned'
      GitTemplate.new path
    rescue Git::GitExecuteError => e
      raise format_git_error_message(e)
    end

    def uninstall
      FileUtils.rm_rf @path
    end

    def check_repository
      @repository.revparse('HEAD')
      if @repository.current_branch.include? 'detached'
        raise "HEAD is detached in local repository. Please fix: #{@path}"
      end
    rescue Git::GitExecuteError => e
      error = "HEAD is not valid in local repository. Please fix: #{@path}\n"
      error += format_git_error_message(e)
      raise error
    end

    def check_tracking_branch
      @repository.revparse('@{u}')
    rescue StandardError
      raise "Local branch '#{@repository.current_branch}' does not track " \
            "an upstream branch in local repository: #{@path}"
    end

    def check_untracked_changes
      message = 'Local repository contains untracked changes. ' \
                "Please fix: #{@path}"
      raise message unless @repository.status.untracked.empty?
    end

    def check_pending_changes
      not_added = @repository.status.added.empty?
      not_deleted = @repository.status.deleted.empty?
      not_changed = @repository.status.changed.empty?
      message = 'Local repository contains modified / staged files. ' \
                "Please fix: #{@path}"
      raise message unless not_added && not_deleted && not_changed
    end

    def update
      check_repository
      check_tracking_branch
      check_untracked_changes
      check_pending_changes
      begin
        @repository.pull
      rescue Git::GitExecuteError => e
        raise format_git_error_message(e)
      end
    end
  end
end
