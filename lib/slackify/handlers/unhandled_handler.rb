# frozen_string_literal: true

module Slackify
  module Handlers
    # Default handler for any text message that is not handler by other handlers
    # This can easily be replaced by setting you own unhandled handler when
    # configuring slackify. Use `#unhandled_handler=` to set it. Your handler
    # must implement a `self.unhandled` method.
    class UnhandledHandler < Base
      def self.unhandled(params)
        slack_client.chat_postMessage(
          as_user: true,
          channel: params[:event][:user],
          text: "This command is not handled at the moment",
        )
      end
    end
  end
end
