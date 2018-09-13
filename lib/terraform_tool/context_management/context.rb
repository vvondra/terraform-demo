require 'terraform_tool/helpers/path_helpers'

module TerraformTool
  module ContextManagement
    class Context
      include TerraformTool::Helpers::PathHelpers

      attr_accessor :name

      def initialize(name:)
        @name = name

        ensure_temp_directory
      end

      def environments
        Dir.glob("#{File.expand_path(File.join(environments_path(@name)))}/*.tfvars").map do |vars_file|
          File.basename(vars_file).split('.')[1]
        end
      end

      private

      def ensure_temp_directory
        unless File.directory?(context_temp_directory(@name))
          Dir.mkdir(context_temp_directory(@name))
        end
      end
    end
  end
end
