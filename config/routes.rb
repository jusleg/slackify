# frozen_string_literal: true

Rails.application.routes.draw do
  post '/slackify/event', to: 'slackify/slack#event_callback'
  post '/slackify/interactive', to: 'slackify/slack#interactive_callback'
  post '/slackify/slash/:handler_class/:handler_method', to: 'slackify/slack#slash_command_callback'
end
