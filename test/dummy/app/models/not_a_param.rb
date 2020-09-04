# frozen_string_literal: true

class NotAParam
  def initialize(value)
    @value = value
  end

  def parse
    raise StandardError, "This should not be called."
  end
end
