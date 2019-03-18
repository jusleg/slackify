# frozen_string_literal: true

module Toddlerbot
  module Exceptions
    class HandlerNotSupported < StandardError; end
    class InvalidHandler < StandardError; end
    class MissingSlashPermission < StandardError; end
  end
end
