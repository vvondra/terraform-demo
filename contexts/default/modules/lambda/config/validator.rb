module TerraformTool
  module Validators
    class LambdaValidator < BaseValidator
      def validate
        within :template_data do
          within :lambda do
            ensure_keys :lambda_version, :functions, :restaurant_api_token

            within :functions do
              ensure_data_type Array

              each do
                ensure_keys :country_code, :restaurant_api_url

                within :partials, optional: true do
                  within :cron, optional: true do
                    ensure_keys :schedule
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
