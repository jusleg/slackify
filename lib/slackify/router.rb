# frozen_string_literal: true

module Slackify
  # In charge of routing a message to its proper handler
  class Router
    class << self
      # List all available commands
      def all_commands
        Slackify.configuration.handlers.collect(&:commands).flatten
      end

      # Find the matching command based on the message string
      def matching_command(message)
        all_commands.each { |command| return command if command.regex.match? message }
        nil
      end

      # Call command based on message string
      def call_command(message, params)
        command = matching_command(message)
        if command.nil?
          return unless Slackify.configuration.unhandled_handler

          Slackify.configuration.unhandled_handler.unhandled(params)
        else
          new_params = params.merge(command_arguments: command.regex.match(message).named_captures)
          command.handler.call(new_params)
        end
      end
    end
  end
end
