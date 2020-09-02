# frozen_string_literal: true

module Slackify
  class RouterTest < ActiveSupport::TestCase
    test "The proper commands get called when receiving slack messages" do
      assert_log_message(:info, regexp: /cool_command called/) do
        Slackify::Router.call_command('wazza', {})
      end

      assert_log_message(:info, regexp: /another_command called/) do
        Slackify::Router.call_command('foo', {})
      end
    end

    test "parameters are parsed correctly" do
      assert_output(/this takes args; int: 1, bool: false, string: foo, float: 0.2/) do
        Slackify::Router.call_command('method3 integer_param=1 string_param=foo float_param=0.2 bool_param=false', {})
      end
    end

    test "Only one command gets called in the event of two regex match. Only the first match is called" do
      assert_log_message(:info, regexp: /cool_command called/) do
        Slackify::Router.call_command('wazza foo', {})
      end

      # checking that we do not output bar
      assert_log_message(:info, regexp: /^((?!another_command called).)*$/) do
        Slackify::Router.call_command('wazza foo', {})
      end
    end

    test "#all_commands returns an array with all the commands" do
      assert_equal(
        ["method 1", "method 2"],
        ["method 1", "method 2"] & Slackify::Router.all_commands.each.collect(&:description)
      )
    end
  end
end
