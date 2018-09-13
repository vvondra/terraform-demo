require 'terraform_tool/generators/context'
require 'terraform_tool/generators/environment'
require 'terraform_tool/generators/module'

module TerraformTool
  class Generate < Thor
    include Thor::Actions
    include Helpers

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'generators', 'templates'))
    end

    include Generators::Context
    include Generators::Environment
    include Generators::Module
  end
end
