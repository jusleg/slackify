# frozen_string_literal: true

require 'test_helper'

module Slackify
  module Handlers
    class ConfigurationTest < ActiveSupport::TestCase
      test "The proper commands get called when receiving slack messages" do
        assert_output(/cool_command called/) do
          Slackify.configuration.handlers.call_command('wazza', {})
        end

        assert_output(/another_command called/) do
          Slackify.configuration.handlers.call_command('foo', {})
        end
      end

      test "Only one command gets called in the event of two regex match. Only the first match is called" do
        assert_output(/cool_command called/) do
          Slackify.configuration.handlers.call_command('wazza foo', {})
        end

        # checking that we do not output bar
        assert_output(/^((?!another_command called).)*$/) do
          Slackify.configuration.handlers.call_command('wazza foo', {})
        end
      end

      test "#all_commands returns an array with all the commands" do
        assert_equal ["method 1", "method 2"], ["method 1", "method 2"] & Slackify.configuration.handlers.all_commands.each.collect(&:description)
      end

      test "Slack auth test is not called if the SLACKIFY_AUTH_SKIP environment variable is set to 1" do
        Rails.stubs(:env).returns('production')
        Slackify::Handlers::Configuration.any_instance.expects(:skip_auth?).returns(true)
        Slack::Web::Client.any_instance.expects(:auth_test).never

        Slackify.load_handlers
      end

      test "Slack auth test is called in the production environment" do
        Rails.stubs(:env).returns('production')
        Slack::Web::Client.any_instance.expects(:auth_test).once.returns('user_id' => 'abc123')

        Slackify.load_handlers
      end

      test "Slack auth test is not called in the test environment" do
        Slack::Web::Client.any_instance.expects(:auth_test).never

        Slackify.load_handlers
      end

      test "#bot_auth_test sets the bot id by calling slack auth test" do
        Slack::Web::Client.any_instance.expects(:auth_test).once.returns('user_id' => 'abc123')

        Slackify.configuration.handlers.bot_auth_test
        assert_equal 'abc123', Slackify.configuration.handlers.bot_id
      end
    end
  end
end
