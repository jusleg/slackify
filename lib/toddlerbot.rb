# frozen_string_literal: true

require 'toddlerbot/configuration'
require 'toddlerbot/engine'
require 'toddlerbot/exceptions'
require 'toddlerbot/handlers/base_handler'
require 'toddlerbot/handlers/handler_validator'
require 'toddlerbot/handlers/unhandled_handler'
require 'toddlerbot/handler_configuration'

Dir[Toddlerbot::Engine.root + 'app/models/**/*.rb'].collect{ |f| require f }

module Toddlerbot
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
      @configuration.handlers = HandlerConfiguration.new
    end
  end
end
