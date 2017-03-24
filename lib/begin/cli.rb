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
      repository.each { |x| Output.info(x) }
    end

    desc 'install PATH', 'Installs a template given its PATH'
    def install(path)
      repo = repository
      template_name = repo.template_name path
      Output.action "Installing template '#{template_name}' from '#{path}'"
      repo.install path, template_name
      Output.success "Template '#{template_name}' successfully installed"
    end

    desc 'uninstall TEMPLATE', 'Uninstalls the named TEMPLATE'
    def uninstall(template)
      template_impl = repository.template template
      Output.action "Uninstalling template #{template}"
      template_impl.uninstall
      Output.success "Template '#{template}' successfully uninstalled"
    end

    desc 'update [TEMPLATE]', 'Updates all templates or one specific TEMPLATE'
    def update(template = nil)
      if template
        template_impl = repository.template template
        Output.action "Updating template #{template}"
        template_impl.update
      else
        repository.each do |x|
          Output.action "Updating template #{x}"
          repository.template(x).update
        end
      end
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
