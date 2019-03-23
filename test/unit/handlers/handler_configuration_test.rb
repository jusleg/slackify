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
    end
  end
end
