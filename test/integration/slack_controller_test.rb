# frozen_string_literal: true

require_relative '../test_helper'

class SlackControllerTest < ActionDispatch::IntegrationTest
  include Toddlerbot::SlackTestHelper

  setup do
    @event_callback_url = "/toddlerbot/event"
    @interactive_callback_url = "/toddlerbot/interactive"
    @slash_command_callback_url = "/toddlerbot/slash/dummy_handler/slash_command"
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

    Toddlerbot.configuration.handlers.expects(:call_command).with(
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

  test "#interactive callback returns the proper following attachement" do
    # Setting up the Slack Ruby Client Mock
    options = { actions: [{ "name" => "btn1", "value" => "btn1", "type" => "button" }], callback_id: "dummy_handler#button_clicked" }
    params = build_slack_interactive_callback(options)

    post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
    assert_equal "{\"attachments\":[{\"text\":\"Test\"}]}", response.body
    assert_response :ok

    options = { actions: [{ "name" => "btn2", "value" => "btn2", "type" => "button" }], callback_id: "dummy_handler#button_clicked" }
    params = build_slack_interactive_callback(options)

    post @interactive_callback_url, as: :json, headers: build_webhook_headers(params), params: params
    assert_equal "{\"attachments\":[{\"text\":\" Button two has been clicked\"}]}", response.body
    assert_response :ok
  end

  test "#slash_command_callback calls the correct handler method" do
    # Passing in the dummy_handler class into url encoded payload
    params = "action=slash_command_callback&channel_id=DD6S3EGQG&channel_name=directmessage&command=%2Ftest&controller=slack&handler_class=dummy_handler&handler_method=slash_command&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FTEAM1234%2F479282542757%2Fvrgf0tsH3Hpatycs5Qop3M9S&team_domain=toddlerbot&team_id=TEAM1234&text=famingo&token=Wxb5WWeegLMp4cIAohut26Lo&trigger_id=478980323267.2152147568.e30db4037a528bde78146858cadd4dd6&user_id=USER1234&user_name=jusleg\""

    DummyHandler.expects(:slash_command).once
    post @slash_command_callback_url, as: :json, headers: build_webhook_headers(params), params: params
    assert_response :ok
  end

  test "#slash_command_callback returns unauthorized with invalid token" do
    params = "action=slash_command_callback&channel_id=DD6S3EGQG&channel_name=directmessage&command=%2Ftest&controller=slack&handler_class=dummy_handler&handler_method=slash_command&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FTEAM1234%2F479282542757%2Fvrgf0tsH3Hpatycs5Qop3M9S&team_domain=toddlerbot&team_id=TEAM1234&text=famingo&token=invalidtoken&trigger_id=478980323267.2152147568.e30db4037a528bde78146858cadd4dd6&user_id=USER1234&user_name=jusleg\""

    post @slash_command_callback_url, headers: build_webhook_headers(params, token: "invalidtoken"), params: params

    assert_response :unauthorized
  end

  test "#slash_command_callback returns unauthorized when over time limit (3000ms)" do
    params = "action=slash_command_callback&channel_id=DD6S3EGQG&channel_name=directmessage&command=%2Ftest&controller=slack&handler_class=dummy_handler&handler_method=slash_command&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FTEAM1234%2F479282542757%2Fvrgf0tsH3Hpatycs5Qop3M9S&team_domain=toddlerbot&team_id=TEAM1234&text=famingo&token=Wxb5WWeegLMp4cIAohut26Lo&trigger_id=478980323267.2152147568.e30db4037a528bde78146858cadd4dd6&user_id=USER1234&user_name=jusleg\""

    post @slash_command_callback_url,
         headers: build_webhook_headers(params, timestamp: Time.now - 31.seconds), params: params

    assert_response :unauthorized
  end

  test "#slash_command_callback raises an exception if the handler method is not whitelisted" do
    # Passing in the dummy_handler class into url encoded payload
    params = "action=slash_command_callback&channel_id=DD6S3EGQG&channel_name=directmessage&command=%2Ftest&controller=slack&handler_class=dummy_handler&handler_method=slash_command_not_permitted&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FTEAM1234%2F479282542757%2Fvrgf0tsH3Hpatycs5Qop3M9S&team_domain=toddlerbot&team_id=TEAM1234&text=famingo&token=Wxb5WWeegLMp4cIAohut26Lo&trigger_id=478980323267.2152147568.e30db4037a528bde78146858cadd4dd6&user_id=USER1234&user_name=jusleg\""

    DummyHandler.expects(:slash_command_not_permitted).never
    assert_raise Toddlerbot::Exceptions::MissingSlashPermission do
      post "/toddlerbot/slash/dummy_handler/slash_command_not_permitted", as: :json, headers: build_webhook_headers(params), params: params
    end
  end
end
