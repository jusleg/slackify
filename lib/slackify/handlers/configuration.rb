# frozen_string_literal: true

require 'ostruct'

module Slackify
  module Handlers
    class Configuration
      attr_reader :bot_id
      attr_accessor :handlers
      delegate :each, to: :@handlers

      def initialize
        @handlers = []

        read_handlers_yaml.each do |handler_yaml|
          handler = generate_handler_from_yaml(handler_yaml)
          @handlers << handler
        end

        environment_configurations
      end

      def all_commands
        @handlers.collect(&:commands).flatten
      end

      def matching_command(message)
        all_commands.each { |command| return command if command.regex.match? message }
        nil
      end

      def call_command(message, params)
        return if params.dig(:event, :user) == @bot_id || params.dig(:event, :message, :user) == @bot_id

        command = matching_command(message)
        if command.nil?
          return unless Slackify.configuration.unhandled_handler

          Slackify.configuration.unhandled_handler.unhandled(params)
        else
          new_params = params.merge(command_arguments: command.regex.match(message).named_captures)
          command.handler.call(new_params)
        end
      end

      def bot_auth_test
        @bot_id = Slackify.configuration.slack_client.auth_test.fetch('user_id')
        Rails.logger.debug("[Slackify] Bot successfully authenticated to Slack")
        true
      rescue KeyError
        raise "[Slackify] The bot did not successfully authenticate to Slack"
      end

      private

      def environment_configurations
        if %w(production staging development).exclude?(Rails.env) || skip_auth?
          @bot_id = 'dummy_bot_id'
        else
          bot_auth_test
        end
      end

      def skip_auth?
        ENV['SLACKIFY_AUTH_SKIP'] == '1'
      end

      def read_handlers_yaml
        raise 'config/handlers.yml does not exist' unless File.exist?("#{Rails.root}/config/handlers.yml")

        YAML.load_file("#{Rails.root}/config/handlers.yml") || []
      end

      def generate_handler_from_yaml(handler_yaml)
        Validator.verify_handler_integrity(handler_yaml)

        handler = OpenStruct.new
        handler.name = handler_yaml.keys.first
        handler.commands = []

        handler_yaml[handler.name]['commands']&.each do |command|
          built_command = OpenStruct.new
          built_command.regex = command['regex']
          built_command.handler = handler.name.camelize.constantize.method(command['action'])
          built_command.description = command['description']
          handler.commands << built_command.freeze
        end

        handler.commands.freeze
        handler.freeze
      end
    end
  end
end
