module TerraformTool
  module Helpers
    module PathHelpers
      def root_path
        File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
      end

      def contexts_path
        File.join(root_path, 'contexts')
      end

      def context_path(context)
        File.join(contexts_path, context)
      end

      def context_temp_directory(context)
        File.join(context_path(context), '.tmp')
      end

      alias_method :context_root_path, :context_path

      def environments_path(context)
        File.join(context_path(context), 'environments')
      end

      def var_file(context, environment)
        File.join(environments_path(context), "terraform.#{environment}.tfvars")
      end

      def plan_file(context, environment)
        File.join(context_temp_directory(context), "terraform.#{environment}.tfplan")
      end

      def state_file(context, environment)
        File.join(context_root_path(context), '.terraform',  'terraform.tfstate')
      end

      def module_path(context, module_name)
        File.join(modules_path(context), module_name)
      end

      def modules_path(context)
        File.join(context_path(context), 'modules')
      end


      def module_config_path(context, module_name)
        File.join(module_path(context, module_name), 'config')
      end

      def module_templates_path(context, module_name)
        File.join(module_path(context, module_name), 'config', 'templates')
      end

      def module_io_file(context, module_name)
        File.read(File.join(module_path(context, module_name), 'io.tf'))
      end

      def module_hooks_path(context, module_name)
        File.join(module_config_path(context, module_name), 'hooks')
      end
    end
  end
end
