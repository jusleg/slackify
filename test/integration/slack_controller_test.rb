# frozen_string_literal: true

require_relative '../test_helper'

module Slackify
  class SlackControllerTest < ActionDispatch::IntegrationTest
    include SlackTestHelper

    setup do
      @event_callback_url = "/slackify/event"
      @interactive_callback_url = "/slackify/interactive"
      @slash_command_callback_url = "/slackify/slash/dummy_handler/slash_command"
    end

    test "#event_callback returns unauthorized for invalid token" do
      params = build_url_verification_params
      post @event_callback_url, as: :json, headers: build_webhook_headers(params, token: "invalidblah"), params: params
      assert_response :unauthorized

      params = build_slack_message_params(event: { channel_type: "im" })
      post @event_callback_url, as: :json, headers: build_webhook_headers(params, token: "invalidblah"), params: params
      assert_response :unauthorized
    end

    test "#event_callback returns unauthorized when over time range" do
      params = build_url_verification_params
      post @event_callback_url, as: :json,
                                headers: build_webhook_headers(params, timestamp: Time.now - 31.seconds), params: params
      assert_response :unauthorized

      params = build_slack_message_params(event: { channel_type: "im" })
      post @event_callback_url, as: :json,
                                headers: build_webhook_headers(params, timestamp: Time.now - 60.seconds), params: params
      assert_response :unauthorized
    end

    test "#event_callback returns with the challenge when event is url_verification" do
      params = build_url_verification_params

      post @event_callback_url, as: :json, headers: build_webhook_headers(params), params: params

      assert_response :ok
      assert_equal "3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P", response.body
    end

    test "#event_callback call the handlers for an IM event" do
      params = build_slack_message_params(event: { channel_type: "im" })

      Slackify::Router.expects(:call_command).with(
        params[:event][:text],
        ActionController::Parameters.new(params)
      )

      post @event_callback_url, as: :json, headers: build_webhook_headers(params), params: params

      assert_response :ok
    end

    test "#interactive_callback returns unauthorized with invalid token" do
      params = build_slack_interactive_callback

      post @interactive_callback_url, headers: build_webhook_headers(params, token: "invalidblah"), params: params

      assert_response :unauthorized
    end

    test "#interactive_callback returns unauthorized when over time range" do
      params = build_slack_interactive_callback

      post @interactive_callback_url,
           headers: build_webhook_headers(params, timestamp: Time.now - 31.seconds), params: params

      assert_response :unauthorized
    end

    test "#interactive_callback call the proper handler" do
      DummyHandler.expects(:cool_command).once
      params = build_slack_interactive_callback
      post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
    end

    test "#interactive_callback call the proper handler when action_id is sent" do
      DummyHandler.expects(:cool_command).once
      params = build_slack_interactive_action
      post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
    end

    test "#interactive_callback returns the proper following blocks" do
      # Setting up the Slack Ruby Client Mock
      options = { view: { callback_id: "dummy_handler#button_clicked" }, actions: [{ "name" => "btn1", "value" => "btn1", "type" => "button" }] }
      params = build_slack_interactive_callback(**options)

      post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
      assert_equal "{\"attachments\":[{\"text\":\"Test\"}]}", response.body
      assert_response :ok

      options = { view: { callback_id: "dummy_handler#button_clicked" }, actions: [{ "name" => "btn2", "value" => "btn2", "type" => "button" }] }
      params = build_slack_interactive_callback(**options)

      post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
      assert_equal "{\"attachments\":[{\"text\":\" Button two has been clicked\"}]}", response.body
      assert_response :ok
    end

    test "#interactive_callback returns the proper following attachement" do
      # Setting up the Slack Ruby Client Mock
      options = { actions: [{ "name" => "btn1", "value" => "btn1", "type" => "button" }], view: { callback_id: "dummy_handler#button_clicked" } }
      params = build_slack_interactive_callback(**options)

      post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
      assert_equal "{\"attachments\":[{\"text\":\"Test\"}]}", response.body
      assert_response :ok

      options = { actions: [{ "name" => "btn2", "value" => "btn2", "type" => "button" }], view: { callback_id: "dummy_handler#button_clicked" } }
      params = build_slack_interactive_callback(**options)

      post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
      assert_equal "{\"attachments\":[{\"text\":\" Button two has been clicked\"}]}", response.body
      assert_response :ok
    end

    test "#interactive_callback raises error if the handler is not supported" do
      options = { actions: [{ "name" => "btn2", "value" => "btn2", "type" => "button" }], view: { callback_id: "random_handler#button_clicked" } }
      params = build_slack_interactive_callback(**options)

      assert_raise Slackify::Exceptions::HandlerNotSupported do
        post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
      end
    end

    test "#slash_command_callback calls the correct handler method" do
      DummyHandler.expects(:slash_command).once
      post @slash_command_callback_url, as: :json, headers: build_webhook_headers(default_params), params: default_params
      assert_response :ok
    end

    test "#slash_command_callback returns unauthorized with invalid token" do
      params = default_params.merge("token": "invalidtoken")

      post @slash_command_callback_url, headers: build_webhook_headers(params, token: "invalidtoken"), params: params

      assert_response :unauthorized
    end

    test "#slash_command_callback returns unauthorized when over time limit (3000ms)" do
      post @slash_command_callback_url, params: default_params,
                                        headers: build_webhook_headers(default_params, timestamp: Time.now - 3.1.seconds)

      assert_response :unauthorized
    end

    test "#slash_command_callback raises an exception if the handler method is not approved" do
      DummyHandler.expects(:slash_command_not_permitted).never
      assert_raise Exceptions::MissingSlashPermission do
        post "/slackify/slash/dummy_handler/slash_command_not_permitted", as: :json,
                                                                          headers: build_webhook_headers(default_params), params: default_params
      end
    end

    test "#slash_command_callback raises an exception if the handler class is not supported" do
      DummyHandler.expects(:slash_command_not_permitted).never
      assert_raise Exceptions::HandlerNotSupported do
        post "/slackify/slash/random_handler_not_permitted/slash_command_not_permitted", as: :json,
                                                                                         headers: build_webhook_headers(default_params), params: default_params
      end
    end

    private

    def default_params
      {
        "action" => "slash_command_callback",
        "channel_id" => "DD6S3EGQG",
        "channel_name" => "directmessage",
        "command" => "/test",
        "controller" => "slack",
        "handler_cl\nass" => "dummy_handler",
        "handler_method" => "slash_command",
        "response_url" => "https://hooks.slack.com/commands/TEAM1234/479282542757/vrgf0tsH3Hpatycs5Qop3\nM9S",
        "team_domain" => "slackify",
        "team_id" => "TEAM1234",
        "text" => "famingo",
        "token" => "Wxb5WWeegLMp4cIAohut26Lo",
        "trigger_id" => "478980323267.2152147568.e30db4037a528bde78146858cadd4\ndd6",
        "user_id" => "USER1234",
        "user_name" => "jusleg"
      }
    end
  end
end
