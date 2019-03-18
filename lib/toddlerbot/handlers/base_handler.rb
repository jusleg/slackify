# frozen_string_literal: true

module Toddlerbot
  class BaseHandler
    class << self
      attr_reader :allowed_slash_methods

      def slack_client
        Toddlerbot.configuration.slack_client
      end

      def allow_slash_method(element)
        if @allowed_slash_methods
          @allowed_slash_methods.push(*element)
        else
          @allowed_slash_methods = Array(element)
        end
      end
    end
  end
end
