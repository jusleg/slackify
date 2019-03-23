# frozen_string_literal: true

require 'slackify/configuration'
require 'slackify/engine'
require 'slackify/exceptions'
require 'slackify/handlers'

module Slackify
  class << self
    attr_writer :configuration
    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def load_handlers
      @configuration.handlers = Handlers::Configuration.new
    end
  end
end
