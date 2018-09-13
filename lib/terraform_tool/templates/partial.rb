module TerraformTool
  module Templates
    class Partial < TemplateBinding

      include TerraformTool::Helpers::PathHelpers
      include Thor::Shell

      def initialize(name:, context:, environment:, module_name:, data:, data_context: nil, force_rendering: true, deep_merge: false)
        @name = name
        @context = context
        @environment = environment
        @module_name = module_name
        @data = data
        @data_context = data_context
        @force_rendering = force_rendering
        @deep_merge = deep_merge

        @defaults = {}
        set(@name, {})

        if data.dig('partials', @name)
          @partial_data_present = true

          @data['partials'][@name].delete('render')

          set(@name, @data['partials'][@name])
        end

      end

      def render
        if partial_data? || @force_rendering
          defaults_file = File.join(module_templates_path(@context, @module_name), 'defaults', "#{@name}.yaml")
          partial_file = File.join(module_templates_path(@context, @module_name), "_#{@name}.tf.erb")

          if File.file?(partial_file)
            partial_template = File.read(partial_file)

            if File.file?(defaults_file)
              @defaults = YAML.load_file(defaults_file, {})

              partial_data = instance_variable_get("@#{@name}")

              if !@deep_merge
                @defaults.each do |key, value|
                  if !partial_data.key?(key)
                    partial_data[key] = value
                  end
                end
              else
                instance_variable_set("@#{@name}", @defaults.deep_merge(partial_data))
              end

            end

            begin
              return Erubis::Eruby.new(partial_template).result(get_binding)
            rescue Exception => e
              say "Error in partial: #{partial_file}", :magenta
              e.backtrace.each { |line| say line, :magenta }
              say e.message, :magenta
              exit 1
            end
          end
        end
      end

      def partial_data?
        @partial_data_present
      end
    end
  end
end
