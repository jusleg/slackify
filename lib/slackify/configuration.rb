# frozen_string_literal: true

require 'slack'

module Slackify
  # Where the configuration for Slackify lives
  class Configuration
    attr_reader :custom_message_subtype_handlers, :slack_bot_token, :unhandled_handler, :custom_event_type_handlers
    attr_accessor :handlers, :slack_secret_token, :slack_client, :approved_bot_ids

    def initialize
      @slack_bot_token = nil
      @slack_secret_token = nil
      @handlers = generate_handlers
      @slack_client = nil
      @custom_message_subtype_handlers = {}
      @custom_event_type_handlers = {}
      @unhandled_handler = Handlers::UnhandledHandler
      @approved_bot_ids = []
    end

    # Set your own unhandled handler
    def unhandled_handler=(handler)
      raise HandlerNotSupported, "#{handler.class} is not a subclass of Slackify::Handlers::Base" unless
        handler < Handlers::Base

      @unhandled_handler = handler
    end

    # Remove unhandled handler. The bot will not reply if the message doesn't
    # match any regex
    def remove_unhandled_handler
      @unhandled_handler = nil
    end

    # Set the token that we will use to connect to slack
    def slack_bot_token=(token)
      @slack_bot_token = token
      @slack_client = Slack::Web::Client.new(token: token)
    end

    # Set a handler for a specific message subtype
    # That handler will have to implement `self.handle_event(params)`
    # see https://api.slack.com/events/message
    def custom_message_subtype_handlers=(event_subtype_hash)
      @custom_message_subtype_handlers = event_subtype_hash.with_indifferent_access
    end

    # Set a handler for a event type
    # That handler will have to implement `self.handle_event(params)`
    # see https://api.slack.com/events
    def custom_event_type_handlers=(event_type_hash)
      @custom_event_type_handlers = event_type_hash.with_indifferent_access
    end

    private

    # Convert a hash to a list of lambda functions that will be called to handle
    # the user messages
    def generate_handlers
      generated_handlers = []
      read_handlers_yaml.each do |handler_hash|
        handler = Handlers::Factory.for(handler_hash)
        generated_handlers << handler
      end

      generated_handlers
    end

    # Reads the config/handlers.yml configuration
    def read_handlers_yaml
      raise 'config/handlers.yml does not exist' unless File.exist?("#{Rails.root}/config/handlers.yml")

      YAML.load_file("#{Rails.root}/config/handlers.yml") || []
    end
  end
end
