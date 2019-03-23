# frozen_string_literal: true

require 'slack'

module Slackify
  class Configuration
    attr_reader :custom_event_subtype_handlers, :slack_bot_token, :unhandled_handler
    attr_accessor :handlers, :slack_secret_token, :slack_client

    def initialize
      @slack_bot_token = nil
      @slack_secret_token = nil
      @handlers = nil
      @slack_client = nil
      @custom_event_subtype_handlers = {}
      @unhandled_handler = Handlers::UnhandledHandler
    end

    def unhandled_handler=(handler)
      raise Exceptions::InvalidHandler, "#{handler.class} is not a subclass of Slackify::Handlers::Base" unless
        handler.is_a?(Handlers::Base)

      @unhandled_handler = handler
    end

    def disable_unhandled_handler
      @unhandled_handler = nil
    end

    def slack_bot_token=(token)
      @slack_bot_token = token
      @slack_client = Slack::Web::Client.new(token: token).freeze
    end

    def custom_event_subtype_handlers=(event_subtype_hash)
      @custom_event_subtype_handlers = event_subtype_hash.with_indifferent_access
    end
  end
end
