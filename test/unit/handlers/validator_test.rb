# frozen_string_literal: true

module Slackify
  module Handlers
    class ValidatorTest < ActiveSupport::TestCase
      test "#verify_handler_integrity doesn't raise on valid hash" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "regex" => /wazza/,
              "action" => 'cool_command',
              "name" => 'wazzzzzzaaa',
            }]
          }
        }

        assert_nothing_raised do
          Validator.verify_handler_integrity(handler_hash)
        end
      end

      test "#verify_handler_integrity raises if the handler doesn't have commands" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => []
          }
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal "dummy_handler doesn't have any command specified", exception.message
      end

      test "#verify_handler_integrity raises if the command doesn't have a regex" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "action" => 'cool_command',
              "name" => 'wazzzzzzaaa',
            }]
          }
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal "dummy_handler is not valid: [wazzzzzzaaa]: No regex was provided.", exception.message
      end

      test "#verify_handler_integrity raises if the command doesn't have a valid action" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "regex" => /wazza/,
              "description" => 'A nice method',
              "action" => 'doesnt_exist',
              "name" => 'wazzzzzzaaa',
            }]
          }
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal "dummy_handler is not valid: [wazzzzzzaaa]: No valid action was provided.", exception.message
      end

      test "#verify_handler_integrity raises and groups command errors" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "action" => 'doesnt_exist',
              "name" => 'wazzzzzzaaa',
            }]
          }
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal "dummy_handler is not valid: [wazzzzzzaaa]: No regex was provided. No valid action was provided.",
          exception.message
      end

      test "#verify_handler_integrity raises if the handler doesn't exist" do
        handler_hash = {
          "null_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "action" => 'doesnt_exist',
              "name" => 'wazzzzzzaaa',
            }]
          }
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal "null_handler is not defined", exception.message
      end
    end
  end
end
