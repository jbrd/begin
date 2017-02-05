require 'begin/repository'
require 'begin/version'
require 'thor'

module Begin
  # The CLI interface for the application.
  class CLI < Thor
    desc 'new TEMPLATE', 'Begin a new project by running the named TEMPLATE'
    def new(template)
      puts "Running template: #{template}"
    end

    desc 'list', 'List installed templates'
    def list
      puts 'Listing installed templates'
    end

    desc 'install PATH', 'Installs a template given its PATH'
    def install(path)
      repository.install path
    end

    desc 'uninstall TEMPLATE', 'Uninstalls the named TEMPLATE'
    def uninstall(template)
      puts "Uninstalling template #{template}"
    end

    desc 'update [TEMPLATE]', 'Updates all templates or one specific TEMPLATE'
    def update(template = nil)
      puts 'Updating all templates' unless template
      puts "Updating #{template}" if template
    end

    desc 'version', 'Prints the version of this command'
    def version
      puts VERSION
    end

    no_commands do
      def repository
        Repository.new
      end
    end
  end
end
