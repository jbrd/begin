require 'begin/output'
require 'begin/path'
require 'rugged'
require 'uri'

module Begin
  # Provides centralised access to the local repository of templates
  # on the machine
  class Repository
    def initialize(name = '.begin', parent_dir = '~')
      @parent_dir = Path.new(parent_dir, '.', 'Repository Parent')
      @parent_dir.ensure_dir_exists
      @repo_dir = Path.new(name, @parent_dir, 'Repository directory')
      @repo_dir.make_dir
      @template_dir = Path.new('templates', @repo_dir, 'Templates directory')
      @template_dir.make_dir
    end

    def list
      Output.action 'Listing installed templates'
    end

    def install(source_uri)
      name = template_name source_uri
      Output.action "Installing template '#{name}' from '#{source_uri}'"
      path = template_path name
      path.ensure_dir_exists
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
      source_path = Path.new source_uri, '.', 'Source path'
      source_path.ensure_dir_exists
      begin
        File.symlink(source_path, path)
        Output.success "Created symbolic link to '#{source_path}'"
      rescue NotImplementedError
        raise NotImplementedError, 'TODO: Copy tree when symlinks not supported'
      end
    end

    def template_name(uri)
      uri = URI(uri)
      path_bits = uri.path.split '/'
      name = path_bits.last
      name = name[6, name.length - 1] if name.start_with? 'begin-'
      name = name[6, name.length - 1] if name.start_with? 'begin_'
      name
    end

    def template_path(template_name)
      Path.new template_name, @template_dir, 'Template directory'
    end
  end
end
