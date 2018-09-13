module TerraformTool
  module ContextManagement
    module Helpers
      include TerraformTool::Helpers::PathHelpers
      def contexts
        puts "loading contexts"

        Dir.glob(File.join(contexts_path, "*")).collect do |context_path|
          Context.new(name: File.basename(context_path))
        end
      end
    end
  end
end
