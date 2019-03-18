# frozen_string_literal: true

Rails.application.routes.draw do
  post '/toddlerbot/event', to: 'toddlerbot/slack#event_callback'
  post '/toddlerbot/interactive', to: 'toddlerbot/slack#interactive_callback'
  post '/toddlerbot/slash/:handler_class/:handler_method', to: 'toddlerbot/slack#slash_command_callback'
end
