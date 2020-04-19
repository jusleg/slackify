# frozen_string_literal: true

module Slackify
  # Makes the whole thing work. Adds the routes for slackify.
  class Engine < Rails::Engine
    isolate_namespace Slackify
  end
end
