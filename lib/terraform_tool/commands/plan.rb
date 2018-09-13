module TerraformTool
  module Commands
    module Plan
      def self.included(thor_class)
        thor_class.class_eval do

          desc "plan", "Runs terraform plan"
          long_desc <<-LONGDESC
            Runs terraform plan.

            With --limit option, the plan run will be limited to the specified resources

            With --modules option, the plan run will be limited to the specified terraform modules

            With --module option, the plan run will be limited to the specified module (only applies to modules managed by
            terraform_tool
          LONGDESC
          option :limit, type: :array, aliases: "-l", default: []
          option :modules, type: :array, aliases: "-m", default: []
          option :destroy, type: :boolean, default: false
          def plan
            module_manager = TerraformTool::Modules::Manager.new(context: context, environment: environment)
            module_manager.clean
            module_manager.render_modules

            init if not dryrun

            if options[:modules].any?
              module_targets =  module_manager.extract_targets(options[:modules])
            else
              module_targets = []
            end

             terraform_command = <<~TERRAFORM_COMMAND
              cd #{context_path(context)} && \
              terraform plan \
              #{"-destroy" if options[:destroy]} \
              -input=false \
              -refresh=true \
              -module-depth=-1 \
              -var-file=#{var_file(context, environment)} \
              -out=#{plan_file(context, environment)} \
              #{aws_profile} #{limit(options[:limit].concat(module_targets))} \
              #{context_path(context)}
             TERRAFORM_COMMAND

             plan_output = syscall(terraform_command.squeeze(' '), dryrun: dryrun, capture: true)

            if plan_output =~ /rds/
              puts
              alert "The changes you intend to deploy contain RDS resources."
              alert "Please make sure to run plan and apply twice."
              alert "Otherwise the read replicas might not pick up your changes."
              puts
            end
          end

        end
      end
    end
  end
end
