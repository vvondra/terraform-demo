require 'terraform_tool/helpers/path_helpers'
require 'terraform_tool/modules/terraform_module'

module TerraformTool
  module Modules

    class Manager
      include Thor::Shell
      include TerraformTool::Helpers::PathHelpers

      def initialize(context:, environment:)
        @context = context
        @environment = environment
        initialize_modules
      end

      def render_modules
        @modules.map(&:process)
      end


      def clean
        @modules.map(&:clean)
      end

      # gets global resources and modules from rendered templates for limiting
      # plan runs
      def extract_targets(module_names)
        targets = []

        @modules.each do |module_instance|

          module_file = File.join(root_path, "#{module_instance.name}.tf")

          if module_names.include?(module_instance.name) && File.file?(module_file)
            File.foreach(module_file) do  |line|
              # extract module names
              if line =~ /module "(.+)" \{/
                targets <<  "module.#{$1}"
              end

              if line =~ /resource "(.+)" "(.+)" \{/
                targets << "#{$1}.#{$2}"
              end
            end
          end
        end
        return targets
      end

      private

      def initialize_modules
        say "Initializing modules", :green

        tfvars_content = File.read(File.join(environments_path(@context), "terraform.#{@environment}.tfvars"))

        if tfvars_content.empty?
          terraform_variables = []
        else
          terraform_variables = HCL::Checker.parse(tfvars_content)
        end

        @modules = []

        Dir.glob("#{modules_path(@context)}/*").each do |directory|
          @modules << TerraformModule.new(
            name: File.basename(directory),
            context: @context,
            environment: @environment,
            terraform_variables: terraform_variables
          )
        end
      end

    end
  end
end
