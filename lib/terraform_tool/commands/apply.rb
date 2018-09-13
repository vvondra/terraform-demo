module TerraformTool
  module Commands
    module Apply
      def self.included(thor_class)
        thor_class.class_eval do

          desc 'apply', 'Applies the current terraform code'
          long_desc <<-LONGDESC
            Applies the current terraform code

            With --limit option, Terraform will only apply changes for the the specified resources

            With --module option, the plan run will be limited to the specified module (only applies to modules managed by
            terraform_tool
          LONGDESC
          option :limit, type: :array, aliases: "-l", required: false, default: nil
          option :module, type: :string, aliases: "-m", default: nil
          def apply
            message_complement = options&.module.nil? ? '' : " Module: #{options&.module}"

            init

            confirm question: "Do you really want to run 'terraform apply' on environment '#{environment}' in context '#{context}'?", color: :on_red, exit_code: 0 do


              if !options[:dryrun]
                slack_notification(
                    context:  context,
                    environment: environment,
                    message: 'is running terraform apply. Wait for it.' + message_complement
                  )
              end

              apply_command = <<~APPLY_COMMAND
                cd #{context_path(context)} && \
                terraform apply \
                -input=true \
                -refresh=true \
                #{limit(options[:limit])} \
                #{plan_file(context, environment)}
              APPLY_COMMAND

              syscall apply_command.squeeze(' '), dryrun: dryrun

              if !options[:dryrun]
                slack_notification(
                    context: context,
                    environment: environment,
                    message: 'applied a new version of me!' + message_complement
                  )
              end
            end
          end
        end

      end
    end
  end
end
