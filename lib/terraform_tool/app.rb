require 'terraform_tool/common'
require 'terraform_tool/generate'
require 'terraform_tool/global_commands/validate'
require 'terraform_tool/context_management/context'
require 'terraform_tool/context_management/helpers'
require 'terraform_tool/templates/template_binding'
require 'terraform_tool/templates/partial'

module TerraformTool

  class Context < Thor; end

  class App < Thor

    extend TerraformTool::Helpers
    extend TerraformTool::Helpers::StringHelpers
    extend TerraformTool::ContextManagement::Helpers

    class_option :dryrun, type: :boolean, default: false, aliases: '-d'

    contexts.each do |context|

      if context.name != 'default'

        # generate class for subcommand within contexts subcommand
        context_subcommand_class = Class.new(Thor)
        context_subcommand_class_name = camel_case(context.name)
        Object.const_set(context_subcommand_class_name, context_subcommand_class)

        TerraformTool::Context.class_eval do
          desc "#{context.name} SUBCOMMAND", "Manage the #{context.name} context."
          subcommand(context.name, const_get(context_subcommand_class_name))
        end
      end

      mod_name = Object.const_set("Module#{camel_case(context.name)}", Module.new)

      context.environments.each do |environment|
        class_name = camel_case(environment)

        klass = Class.new(TerraformTool::Common)

        mod_name.const_set(class_name, klass)

        klass.class_eval do
          @context = context.name
          @environment = environment

          def self.context
            @context
          end

          def self.environment
            @environment
          end
        end


        if context.name == 'default'
          # attach subcommands for the standard environments directly
          # eg.:
          # ./terraform_tool production_eu SUBCOMMAND
          desc "#{environment} SUBCOMMAND", "Manage the #{environment} environment in context default"
          subcommand(environment, mod_name.const_get(class_name))
        else
          const_get(context_subcommand_class_name).class_eval do
            desc "#{environment} SUBCOMMAND", "Manage the #{environment} environment in context #{context.name}"
            subcommand(environment, mod_name.const_get(class_name))
          end
        end
      end
    end

    desc 'generate SUBCOMMAND', 'Generators for modules and environments'
    subcommand('generate', TerraformTool::Generate)

    desc 'context SUBCOMMAND', 'Context subcommands'
    subcommand('context', Context)

    include TerraformTool::GlobalCommands::Validate
  end
end
