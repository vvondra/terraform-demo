require 'terraform_tool/validators/validation_error'
require 'terraform_tool/validators/validation_helpers'
require 'terraform_tool/validators/validation_dsl'

module TerraformTool
  module Validators
    class BaseValidator
      include ValidationDSL
      include ValidationHelpers

      def initialize(data, environment)
        @data = data
        @environment = environment
        validate
      end

      private

      def validate
        raise "Override this method in your module validator class."
      end
    end
  end
end
