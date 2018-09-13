module TerraformTool
  module Helpers
    module StringHelpers
      def camel_case(input)
        input.split('_').collect(&:capitalize).join
      end
    end
  end
end
