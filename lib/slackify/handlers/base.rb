# frozen_string_literal: true

module Slackify
  module Handlers
    # Base handler class that any user defined handlers must inherit from
    class Base
      @@supported_handlers = []

      class << self
        attr_reader :allowed_slash_methods

        # Get the slack client that you can use to perform slack api calls
        # @see https://github.com/slack-ruby/slack-ruby-client
        def slack_client
          Slackify.configuration.slack_client
        end

        # Enables a method to be called for a slash command.
        #
        # More context:
        # Slash commands have extra validations. To call a slash command, it
        # needs to call a method on a supported handler and that handler needs
        # to explicitly specify which methods are for slash command.
        def allow_slash_method(element)
          if defined?(@allowed_slash_methods) && @allowed_slash_methods
            @allowed_slash_methods.push(*element)
          else
            @allowed_slash_methods = Array(element)
          end
        end

        # Any class inheriting from Slackify::Handler::Base will be added to
        # the list of supported handlers
        def inherited(subclass)
          @@supported_handlers.push(subclass.to_s)
          super
        end

        # Show a list of the handlers supported by the app. Since we do
        # metaprogramming, we want to ensure we can only call defined handlers
        def supported_handlers
          @@supported_handlers
        end
      end
    end
  end
end
