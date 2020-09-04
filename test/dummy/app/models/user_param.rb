# frozen_string_literal: true

class UserParam < Slackify::Parameter
  def initialize(value)
    @value = value
  end

  def parse
    if @value == 'W12345TG'
      "Doug Edey"
    else
      "Foo"
    end
  end
end
