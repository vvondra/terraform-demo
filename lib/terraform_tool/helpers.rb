require 'pty'
require 'json'
require 'net/http'
require 'terraform_tool/helpers/path_helpers'
require 'date'

module TerraformTool
  module Helpers
    include TerraformTool::Helpers::PathHelpers

    ERROR = :red

    DEFAULT = :green

    SLACK_WEBHOOK_URLS = {
      staging: "https://hooks.slack.com/services/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",
      qa: "https://hooks.slack.com/services/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",
      production: "https://hooks.slack.com/services/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"
    }

    def alert(message)
      say "#{message}", :on_red
    end

    def limit(resources)
      resources ? resources.inject("") {
        |memo, resource| "#{memo} -target=#{resource}" } : ""
    end

    def confirm(question:, color:, exit_on_no: true, exit_code: 1)
      if ask(question, color, limited_to: ["yes", "no"]) == "yes"
        yield if block_given?
      else
        if exit_on_no
          say "Exiting.", ERROR
          exit exit_code
        end
      end
    end

    def current_user
      Etc.getpwnam(Etc.getlogin).gecos
    end

    def slack_notification(context:, environment:, message:)
      webhook_url = case environment
                when /qa/
                  SLACK_WEBHOOK_URLS[:qa]
                when /staging/
                  SLACK_WEBHOOK_URLS[:staging]
                when /production/
                  SLACK_WEBHOOK_URLS[:production]
                else
                  nil
                end

      if webhook_url
        time = DateTime.now.strftime("%Y/%m/%d - %H:%M")
        slack_payload = {
          text: "[#{context} - #{environment} - #{time}] #{current_user} #{message}"
        }.to_json

        uri = URI(webhook_url)

        request = Net::HTTP::Post.new(uri)
        request.body = slack_payload

        request_options = {
          use_ssl: uri.scheme == "https",
        }

        Net::HTTP::start(uri.hostname, uri.port, request_options) do |http|
          http.request(request)
        end
      end
    end

    def syscall(command, dryrun: false, capture: false)
      say "Executing: #{command}\n\n", :green

      output = ""

      if not dryrun
        begin
          PTY.spawn(command) do |stdout, stdin, pid|
            stdout.each do |line|
              output << line
              puts line
            end
          end
        rescue Errno::EIO # GNU/Linux raises EIO.
          nil
        end
      end
      return output
    end
  end
end
