# frozen_string_literal: true

module Slackify
  # In charge of routing a message to its proper handler
  class Router
    MATCHING_QUOTES = {
      "'": "'",
      '"': '"',
      '“': "”",
    }.freeze

    class << self
      # List all available commands
      def all_commands
        Slackify.configuration.handlers.collect(&:commands).flatten
      end

      # Find the matching command based on the message string
      def matching_command(message)
        all_commands.each do |command|
          return command if command.regex.present? && command.regex.match?(message)
          return command if command.base_command.present? && message.start_with?(command.base_command)
        end
        nil
      end

      # Call command based on message string
      def call_command(message, params)
        command = matching_command(message)
        if command.nil?
          return unless Slackify.configuration.unhandled_handler

          Slackify.configuration.unhandled_handler.unhandled(params)
        else
          new_params = params.merge( command_arguments: extract_arguments(message, command) )

          command.handler.call(new_params)
        end
      end

      def extract_arguments(message, command)
        if command.regex
          command.regex.match(message).named_captures
        else
          raw_arguments = message.sub(/^#{command.base_command}/, '').strip
          spec = {}
          command.parameters.each do |parameter|
            spec[parameter.keys[0].to_sym] = { type: parameter.values[0].to_sym }
          end
          parse_by_spec(spec, raw_arguments)
        end
      end

      def parse_by_spec(spec, raw_arguments)
        processed_args = {}

        s = StringScanner.new(raw_arguments)
        until s.eos?
          # get the key, remove '=' and extra whitespace
          current_key = s.scan_until(/=/)
          break if current_key.nil?

          current_key = current_key[0..-2].strip

          # grab value accounting for any quotes
          next_char = s.getch
          terminating_string = if (end_quote = MATCHING_QUOTES[next_char.to_sym])
                                 /#{end_quote}/
                               else
                                 s.unscan
                                 / /
                               end

          processed_args[current_key.to_sym] = if s.exist?(terminating_string)
                                                 # grab everything before the next instance of the terminating character
                                                 s.scan_until(terminating_string)[0..-2]
                                               else
                                                 # this is probably wrong unless we were expecting a space, but hit eos
                                                 s.rest
                                               end
        end

        # only pass on expected parameters for now.
        processed_spec = {}
        spec.each do |key, value|
          # coerce to the expected type
          type = value.fetch(:type, 'string')
          processed_spec[key] = case type
                                when :int
                                  processed_args[key].to_i
                                when :float
                                  processed_args[key].to_f
                                when :boolean
                                  ActiveModel::Type::Boolean.new.cast(processed_args[key])
                                when :string
                                  processed_args[key]
                                else
                                  Object.const_get(type).new(processed_args[key]).parse
                                end
        end

        processed_spec
      end
    end
  end
end
