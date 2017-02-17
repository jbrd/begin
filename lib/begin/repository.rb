require 'begin/output'
require 'begin/path'
require 'rugged'
require 'uri'

module Begin
  # Provides centralised access to the local repository of templates
  # on the machine
  class Repository
    def initialize(name = '.begin', parent_dir = '~')
      @parent_dir = Path.new parent_dir
      check_parent_dir
      @repo_dir = Path.new name, @parent_dir
      check_repo_dir
      @template_dir = Path.new 'templates', @repo_dir
      check_template_dir
    end

    def check_parent_dir
      # Parent dir must be a directory and must exist
      unless File.exist? @parent_dir
        raise IOError, "Repository parent '#{@parent_dir}' does not exist"
      end
      return if File.directory? @parent_dir
      raise IOError, "Repository parent '#{@parent_dir}' is not a directory"
    end

    def check_repo_dir
      # Repo folder can be created on demand if it doesn't
      # already exist but must always be a directory.
      unless File.exist? @repo_dir
        Begin::Output.action "Making directory '#{@parent_dir}'"
        Dir.mkdir @repo_dir
      end
      return if File.directory? @repo_dir
      raise IOError, "Repository directory '#{@repo_dir}' is not a directory"
    end

    def check_template_dir
      unless File.exist? @template_dir
        Begin::Output.action "Making directory '#{@template_dir}'"
        Dir.mkdir @template_dir
      end
      return if File.directory? @template_dir
      raise IOError, "Template directory '#{@template_dir}' is not a directory"
    end

    def list
      Output.action 'Listing installed templates'
    end

    def install(source_uri)
      name = template_name source_uri
      Output.action "Installing template '#{name}' from '#{source_uri}'"
      path = template_path name
      check_template_path path
      Output.info "Installing to '#{path}'"
      try_install source_uri, path
      Output.success "Template '#{name}' successfully installed"
    end

    def uninstall(template)
      Output.action "Uninstalling template #{template}"
    end

    def update(template = nil)
      Output.action 'Updating all templates' unless template
      Output.action "Updating template #{template}" if template
    end

    def try_install(source_uri, path)
      try_install_git_template source_uri path
    rescue Rugged::NetworkError, Rugged::RepositoryError
      try_install_local_template source_uri, path
    end

    def try_install_git_template(source_uri, path)
      Rugged::Repository.clone_at(source_uri, path)
      Output.success 'Template source was successfully git cloned'
    end

    def try_install_local_template(source_uri, path)
      source_path = Path.new source_uri
      check_local_template_source source_path
      begin
        File.symlink(source_path, path)
        Output.success "Created symbolic link to '#{source_path}'"
      rescue NotImplementedError
        raise NotImplementedError, 'TODO: Copy tree when symlinks not supported'
      end
    end

    def check_local_template_source(source_path)
      unless File.exist? source_path
        raise IOError, "Template source '#{source_path}' was not reachable"
      end
      return if File.directory? source_path
      raise IOError, "Template source '#{source_path}' is not a directory"
    end

    def template_name(source_uri)
      uri = URI(source_uri)
      path_bits = uri.path.split '/'
      name = path_bits.last
      name = name[6, name.length - 1] if name.start_with? 'begin-'
      name = name[6, name.length - 1] if name.start_with? 'begin_'
      name
    end

    def template_path(template_name)
      File.join [@template_dir, template_name]
    end

    def check_template_path(path)
      return unless File.exist? path
      unless File.directory? path
        raise IOError, "Template directory '#{path}' is not a directory"
      end
      return if Dir.glob(File.join([path, '*'])).empty?
      raise IOError, "Template already installed at '#{path}'"
    end
  end
end
