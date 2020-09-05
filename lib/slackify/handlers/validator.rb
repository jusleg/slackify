# frozen_string_literal: true

module Slackify
  module Handlers
    # Simple validator for handlers. It will blow your app up on the
    # configuration step instead of crashing when handling production requests.
    class Validator
      VALID_PARAMETER_TYPES = [:string, :int, :boolean, :float].freeze

      class << self
        # Checks if your handler hash is valid. It's pass or raise 🧨💥
        def verify_handler_integrity(handler)
          handler_name = handler.keys.first
          handler_class = handler_name.camelize.constantize

          unless handler[handler_name].key?('commands') && handler.dig(handler_name, 'commands')&.any?
            raise Exceptions::InvalidHandler, "#{handler_name} doesn't have any command specified"
          end

          handler_errors = []

          handler.dig(handler_name, 'commands').each do |command|
            command_errors = []

            unless command['regex'] || command['base_command']
              command_errors.append('No regex or base command was provided.')
            end

            if command['regex'].present?
              if command['base_command'].present?
                command_errors.append('Regex and base_command cannot be used in the same handler.')
              end

              if command['parameters'].present?
                command_errors.append('Regex and parameters cannot be used in the same handler.')
              end

              unless command['regex'].is_a?(Regexp)
                command_errors.append('No regex was provided.')
              end
            end

            if command['base_command']
              unless command['base_command'].is_a?(String)
                command_errors.append('Invalid base command provided, it must be a string.')
              end

              if command['parameters'].present?
                command_errors << validate_parameters(command['parameters'])
              end
            end

            unless !command['action'].to_s.strip.empty? && handler_class.respond_to?(command['action'])
              command_errors.append('No valid action was provided.')
            end
            command_errors = command_errors.flatten.compact
            handler_errors.append("[#{command['name']}]: #{command_errors.join(' ')}") unless command_errors.empty?
          end

          unless handler_errors.empty?
            raise Exceptions::InvalidHandler, "#{handler_name} is not valid: #{handler_errors.join(' ')}"
          end
        rescue NameError
          raise Exceptions::InvalidHandler, "#{handler_name} is not defined"
        end

        def validate_parameters(parameters)
          errors = []
          parameters.each do |parameter|
            key = parameter.keys[0]
            type = parameter.values[0]

            next if VALID_PARAMETER_TYPES.include?(type.to_sym)

            type.constantize
            next if Slackify::Parameter.supported_parameters.include?(type)

            errors << "Invalid parameter type for: #{key}, '#{type}'.\n"\
              "If this is a custom parameter, make sure it inherits from Slackify::Parameter"
          rescue NameError
            errors << "Failed to find the custom class for: #{key}, '#{type}'."
          end
          errors
        end
      end
    end
  end
end
