# frozen_string_literal: true

require 'slack'

module Toddlerbot
  class Configuration
    attr_reader :custom_event_subtype_handlers, :slack_bot_token
    attr_accessor :handlers, :slack_secret_token, :slack_client

    def initialize
      @slack_bot_token = nil
      @slack_secret_token = nil
      @handlers = nil
      @slack_client = nil
      @custom_event_subtype_handlers = {}
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
