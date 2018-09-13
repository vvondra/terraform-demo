require 'terraform_tool/commands/apply'
require 'terraform_tool/commands/clean'
require 'terraform_tool/commands/destroy'
require 'terraform_tool/commands/graph'
require 'terraform_tool/commands/import'
require 'terraform_tool/commands/move'
require 'terraform_tool/commands/output'
require 'terraform_tool/commands/plan'
require 'terraform_tool/commands/remove'
require 'terraform_tool/commands/render'
require 'terraform_tool/commands/taint'

module TerraformTool
  class Common < Thor
    include Helpers
    include TerraformTool::Helpers::PathHelpers

    TerraformTool::Commands.constants.each do |command|
      include const_get("TerraformTool::Commands::#{command}")
    end

    private

    def context
      self.class.context
    end

    def environment
      self.class.environment
    end

    def init
      event_bus_tf_path = File.join(context_path('default'), 'event_bus.tf')

      if File.file?(event_bus_tf_path)
        File.delete(event_bus_tf_path)
      end

      say "initializing", :green
      say "environment: #{environment}", :green

      `rm -rf #{context_path(context)}/.terraform/*.tf*`
      `rm -rf #{context_path(context)}/.terraform/modules`

      terraform_command = <<~TERRAFORM_COMMAND
        cd #{context_path(context)} && \
        terraform init \
        -backend-config='key=#{context}-#{environment}.tfstate' \
        #{aws_profile} \
        #{context_path(context)}
      TERRAFORM_COMMAND

      syscall terraform_command.squeeze(' ')
    end

    def aws_profile
      # CHANGEME
      # Change this to return an AWS profile of your own account
      environment.start_with?("production") ?
        "-var 'aws_profile=logistics-production'" :
        "-var 'aws_profile=logistics-staging'"
    end

    def dryrun
      parent_options[:dryrun]
    end

  end
end
