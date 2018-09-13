require 'terraform_tool/modules/manager'

module TerraformTool
  module Commands
    module Render
      def self.included(thor_class)
        thor_class.class_eval do

          desc "render", "Renders the module templates"
          long_desc <<-LONGDESC
            Renders the module templates without running Terraform
          LONGDESC
          def render
            module_manager = TerraformTool::Modules::Manager.new(context: context, environment: environment)
            module_manager.render_modules
          end

        end
      end
    end
  end
end
