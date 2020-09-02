# frozen_string_literal: true

class DummyHandler < Slackify::Handlers::Base
  allow_slash_method :slash_command

  class << self
    def cool_command(_params)
      Rails.logger.info("cool_command called")
    end

    def another_command(_params)
      Rails.logger.info("another_command called")
    end

    def button_clicked(params)
      response = {}
      case params["actions"].first["name"]
      when "btn1"
        response[:attachments] = [{
          "text": "Test",
        }]
      when "btn2"
        response[:attachments] = [{
          "text": " Button two has been clicked",
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

    def method_3_command(params)
      puts "this takes args; "\
        "int: #{params[:command_arguments][:integer_param]}, "\
        "bool: #{params[:command_arguments][:bool_param]}, "\
        "string: #{params[:command_arguments][:string_param]}, "\
        "float: #{params[:command_arguments][:float_param]}"
    end
  end
end
