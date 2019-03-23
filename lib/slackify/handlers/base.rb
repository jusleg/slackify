# frozen_string_literal: true

module Slackify
  module Handlers
    class Base
      @@supported_handlers = []

      class << self
        attr_reader :allowed_slash_methods

        def slack_client
          Slackify.configuration.slack_client
        end

        def allow_slash_method(element)
          if @allowed_slash_methods
            @allowed_slash_methods.push(*element)
          else
            @allowed_slash_methods = Array(element)
          end
        end

        def inherited(subclass)
          @@supported_handlers.push(subclass.to_s)
        end

        def supported_handlers
          @@supported_handlers
        end
      end
    end
  end
end
