# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require_relative 'slack_test_helper'
require "rails/test_help"
require 'mocha/minitest'
require 'byebug'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

module ActiveSupport
  class TestCase
    # returns a tuple of found_logs (Array), and result (whatever the block returns)
    def assert_log_message(log_level, logger: Rails.logger, regexp: nil, message: nil, &block)
      add_log_expectation(log_level, logger: logger, run_assertion: true, regexp: regexp, message: message, &block)
    end

    # returns a tuple of found_logs (Array), and result (whatever the block returns)
    def refute_log_message(log_level, logger: Rails.logger, regexp: nil, message: nil, &block)
      add_log_expectation(log_level, logger: logger, run_assertion: false, regexp: regexp, message: message, &block)
    end

    def add_log_expectation(log_level, logger:, run_assertion: true, regexp: nil, message: nil)
      found_lines = []
      all_lines = []

      logger.expects(log_level).with do |line|
        if (regexp && line =~ regexp) || (line == message)
          found_lines << line if line.present?
        end
        all_lines << line if line.present?

        true
      end.at_least(0)

      result = yield

      if run_assertion
        message = "Expected log #{log_level} not found with message: \n#{regexp || message}\n"
        if all_lines.empty?
          message += "No logs found."
        else
          message += "Logs found:\n"
          message += "=============\n"
          message += all_lines.join("\$\n")
          message += "\n=============\n\n"
        end
        assert(found_lines.present?, message: message)
      else
        message = "Expected to not log #{log_level} with message \n'#{regexp || message}' but it was logged.\n"
        if found_lines.present?
          message += "Logs found:\n"
          message += "=============\n"
          message += found_lines.join("\$\n")
          message += "\n=============\n\n"
        end
        assert(found_lines.blank?, message: message)
      end
      [found_lines, result]
    end
  end
end
