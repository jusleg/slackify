# frozen_string_literal: true

module Toddlerbot
  class HandlerValidator
    def self.verify_handler_integrity(handler)
      handler_name = handler.keys.first
      handler_class = handler_name.camelize.constantize

      unless handler[handler_name].key?('commands') && handler.dig(handler_name, 'commands')&.any?
        raise Toddlerbot::Exceptions::InvalidHandler, "#{handler_name} doesn't have any command specified"
      end

      handler_errors = []

      handler.dig(handler_name, 'commands').each do |command|
        command_errors = []

        unless command['regex'].is_a?(Regexp)
          command_errors.append('No regex was provided.')
        end

        unless !command['action'].to_s.strip.empty? && handler_class.respond_to?(command['action'])
          command_errors.append('No valid action was provided.')
        end

        handler_errors.append("[#{command['name']}]: #{command_errors.join(' ')}") unless command_errors.empty?
      end

      unless handler_errors.empty?
        raise Toddlerbot::Exceptions::InvalidHandler, "#{handler_name} is not valid: #{handler_errors.join(' ')}"
      end
    rescue NameError
      raise Toddlerbot::Exceptions::InvalidHandler, "#{handler_name} is not defined"
    end
  end
end