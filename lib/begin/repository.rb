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

    def install(source_uri, name)
      @repo_dir.make_dir
      @template_dir.make_dir
      path = template_path name
      Output.info "Installing to '#{path}'"
      begin
        return GitTemplate.install source_uri, path
      rescue Rugged::NetworkError, Rugged::RepositoryError
        return SymlinkTemplate.install source_uri, path
      end
    end

    def each
      templates = @template_dir.dir_contents
      templates.each { |x| yield template_name x }
    end

    def template(name)
      path = template_path name
      template_from_path path
    end

    def template_name(uri)
      uri = URI(uri)
      path_bits = uri.path.split '/'
      name = path_bits.last
      name.slice! 'begin-'
      name.slice! 'begin_'
      name.chomp! '.git'
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
