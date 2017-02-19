require 'begin/output'
require 'begin/path'
require 'begin/template'
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
      @template_dir = Path.new('templates', @repo_dir, 'Templates directory')
    end

    def list
      templates = Dir.glob(File.join([@template_dir, '*']))
      templates.each { |x| Output.info(template_name(x)) }
    end

    def install(source_uri)
      name = template_name source_uri
      Output.action "Installing template '#{name}' from '#{source_uri}'"
      @repo_dir.make_dir
      @template_dir.make_dir
      path = template_path name
      Output.info "Installing to '#{path}'"
      try_install source_uri, path
      Output.success "Template '#{name}' successfully installed"
    end

    def try_install(source_uri, path)
      GitTemplate.install source_uri, path
    rescue Rugged::NetworkError, Rugged::RepositoryError
      SymlinkTemplate.install source_uri, path
    end

    def uninstall(template_name)
      path = template_path template_name
      template = template_from_path path
      Output.action "Uninstalling template #{template_name}"
      template.uninstall
      Output.success "Template '#{template_name}' successfully uninstalled"
    end

    def update(template = nil)
      Output.action 'Updating all templates' unless template
      Output.action "Updating template #{template}" if template
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

    def template_from_path(path)
      return SymlinkTemplate.new(path) if File.symlink? path
      GitTemplate.new path
    end
  end
end
