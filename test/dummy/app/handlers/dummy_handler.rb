# frozen_string_literal: true

class DummyHandler < Slackify::Handlers::Base
  allow_slash_method :slash_command

  class << self
    def cool_command(_params)
      # we just check that the output is the right one
      puts "cool_command called"
    end

    def another_command(_params)
      # we just check that the output is the right one
      puts "another_command called"
    end

    def button_clicked(params)
      response = {}
      case params["actions"].first["name"]
      when "btn1"
        response[:attachments] = [{
          "text": "Test"
        }]
      when "btn2"
        response[:attachments] = [{
          "text": " Button two has been clicked"
        }]
      end
      response
    end

    def slash_command(_params)
      "dummy_handler slash_command() was called"
    end

    def slash_command_not_permitted(_params)
      "this should never be called"
    end
  end
end
