# frozen_string_literal: true

module Slackify
  module Handlers
    class UnhandledHandler < Base
      def self.unhandled(params)
        slack_client.chat_postMessage(
          as_user: true,
          channel: params[:event][:user],
          text: "This command is not currently handled at the moment",
        )
      end
    end
  end
end
