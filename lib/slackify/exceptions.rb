# frozen_string_literal: true

module Slackify
  # When things go boom, we need these.
  module Exceptions
    # You tried to call a class that was not extending the base handler
    class HandlerNotSupported < StandardError; end
    # You handler is failing validations
    class InvalidHandler < StandardError; end
    # The handler method was not approved to be a slash command
    class MissingSlashPermission < StandardError; end
  end
end
