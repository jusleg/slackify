# frozen_string_literal: true

module Slackify
  module Handlers
    # Creates the handler structs
    class Factory
      def self.for(configuration)
        Validator.verify_handler_integrity(configuration)

        handler = OpenStruct.new
        handler.name = configuration.keys.first
        handler.commands = []

        configuration[handler.name]['commands']&.each do |command|
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
