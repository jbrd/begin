require 'begin/output'
require 'begin/repository'
require 'begin/version'
require 'thor'

module Begin
  # The CLI interface for the application.
  class CLI < Thor
    desc 'new TEMPLATE', 'Begin a new project by running the named TEMPLATE'
    def new(template)
      Output.action "Running template: #{template}"
    end

    desc 'list', 'List installed templates'
    def list
      repository.list
    end

    desc 'install PATH', 'Installs a template given its PATH'
    def install(path)
      repository.install path
    end

    desc 'uninstall TEMPLATE', 'Uninstalls the named TEMPLATE'
    def uninstall(template)
      repository.uninstall template
    end

    desc 'update [TEMPLATE]', 'Updates all templates or one specific TEMPLATE'
    def update(template = nil)
      repository.update template
    end

    desc 'version', 'Prints the version of this command'
    def version
      Output.info VERSION
    end

    no_commands do
      def repository
        Repository.new
      end
    end
  end
end
