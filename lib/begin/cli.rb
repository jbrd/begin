require 'begin/input'
require 'begin/output'
require 'begin/repository'
require 'begin/version'
require 'thor'
require 'yaml'

module Begin
  # The CLI interface for the application.
  class CLI < Thor
    desc 'new TEMPLATE', 'Begin a new project by running the named TEMPLATE'
    option :yaml, desc: 'Do not prompt user for tag values. ' \
                        'Instead, take them from given YAML file.'
    def new(template)
      template_impl = repository.template template
      context = if options[:yaml]
                  YAML.load_file(options[:yaml])
                else
                  Input.prompt_user_for_tag_values(template_impl.config.tags)
                end
      Output.action "Running template '#{template}'"
      template_impl.run Dir.getwd, context
      Output.success "Template '#{template}' successfully run"
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
