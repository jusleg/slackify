# frozen_string_literal: true

module Toddlerbot
  class UnhandledHandler < Toddlerbot::BaseHandler
    class << self
      def unhandled(params)
        slack_client.chat_postMessage(
          as_user: true,
          channel: params[:event][:user],
          text: "This command is not currently handled at the moment",
        )
      end
    end
  end
end
