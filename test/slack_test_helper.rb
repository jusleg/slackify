# frozen_string_literal: true

module Slackify
  module SlackTestHelper
    def build_url_verification_params(**options)
      {
        token: "testslacktoken123",
        challenge: "3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P",
        type: "url_verification",
      }.deep_merge(options)
    end

    def build_slack_message_params(**options)
      {
        token: "testslacktoken123",
        team_id: "TEAM1234",
        api_app_id: "APPID1234",
        event: {
          type: "message",
          channel: "CHANNEL123",
          user: "U2147483697",
          text: "hello world",
          ts: "1355517523.000005",
          event_ts: "1355517523.000005",
          channel_type: "channel",
        },
        type: "event_callback",
        authed_teams: %w(
          TEAM1234
        ),
        event_id: "EVENT1234",
        event_time: "1355517523",
      }.deep_merge(options)
    end

    def build_slack_interactive_callback(**options)
      {
        payload: {
          type: "interactive_message",
          view: {
            callback_id: "dummy_handler#cool_command",
            type: 'modal',
            title: {
              type: 'plain_text',
              text: 'Modal with inputs',
            },
          },
          actions: [
            {
              name: "btn1",
              value: "btn1",
              type: "button",
            },
          ],
          team: {
            id: "TEAM1234",
            domain: "famingo",
          },
          channel: {
            id: "CHANNEL1234",
            name: "famingo-labs",
          },
          user: {
            id: "USER1234",
            name: "jusleg",
          },
          action_ts: "1458170917.164398",
          message_ts: "1458170866.000004",
          attachment_id: "1",
          token: "testslacktoken123",
          original_message: {

          },
          trigger_id: "13345224609.738474920.8088930838d88f008e0",
        }.deep_merge(options).to_json,
      }
    end

    def build_legacy_slack_interactive_callback(**options)
      {
        payload: {
          type: "interactive_message",
          actions: [
            {
              name: "btn1",
              value: "btn1",
              type: "button",
            },
          ],
          callback_id: "dummy_handler#cool_command",
          team: {
            id: "TEAM1234",
            domain: "famingo",
          },
          channel: {
            id: "CHANNEL1234",
            name: "famingo-labs",
          },
          user: {
            id: "USER1234",
            name: "jusleg",
          },
          action_ts: "1458170917.164398",
          message_ts: "1458170866.000004",
          attachment_id: "1",
          token: "testslacktoken123",
          original_message: {
          },
          trigger_id: "13345224609.738474920.8088930838d88f008e0",
        }.deep_merge(options).to_json,
      }
    end

    def build_webhook_headers(params, timestamp: Time.now, token: "123abcslacksecrettokenabc123")
      {
        "X-Slack-Signature": "v0=" +
          OpenSSL::HMAC.hexdigest("sha256", token, "v0:#{timestamp.to_i}:#{params.to_json}"),
        "X-Slack-Request-Timestamp": timestamp.to_i,
      }
    end
  end
end
