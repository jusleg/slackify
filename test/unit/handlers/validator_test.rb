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
            }],
          },
        }

        assert_nothing_raised do
          Validator.verify_handler_integrity(handler_hash)
        end
      end

      test "#verify_handler_integrity raises if the handler doesn't have commands" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [],
          },
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
            }],
          },
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal "dummy_handler is not valid: [wazzzzzzaaa]: No regex or base command was provided.",
          exception.message
      end

      test "#verify_handler_integrity raises if the command doesn't have a valid action" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "regex" => /wazza/,
              "description" => 'A nice method',
              "action" => 'doesnt_exist',
              "name" => 'wazzzzzzaaa',
            }],
          },
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
            }],
          },
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal(
          "dummy_handler is not valid: [wazzzzzzaaa]: No regex or base command was provided. "\
            "No valid action was provided.",
          exception.message
        )
      end

      test "#verify_handler_integrity raises invalid regex error" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "action" => 'cool_command',
              "name" => 'wazzzzzzaaa',
              "regex" => 123,
            }],
          },
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal(
          "dummy_handler is not valid: [wazzzzzzaaa]: No regex was provided.",
          exception.message
        )
      end

      test "#verify_handler_integrity raises invalid base command error" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "action" => 'cool_command',
              "name" => 'wazzzzzzaaa',
              "base_command" => 123,
            }],
          },
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal(
          "dummy_handler is not valid: [wazzzzzzaaa]: No base command was provided.",
          exception.message
        )
      end

      test "#verify_handler_integrity raises conflict when regex and base_command is used" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "action" => 'cool_command',
              "name" => 'wazzzzzzaaa',
              "base_command" => "foo",
              "regex" => /wazza/,
            }],
          },
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal(
          "dummy_handler is not valid: [wazzzzzzaaa]: Regex and base_command cannot be used in the same handler.",
          exception.message
        )
      end

      test "#verify_handler_integrity raises conflict when regex and parameters is used" do
        handler_hash = {
          "dummy_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "action" => 'cool_command',
              "name" => 'wazzzzzzaaa',
              "parameters" => [{ "integer_param" => "int" }],
              "regex" => /wazza/,
            }],
          },
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal(
          "dummy_handler is not valid: [wazzzzzzaaa]: Regex and parameters cannot be used in the same handler.",
          exception.message
        )
      end

      test "#verify_handler_integrity raises if the handler doesn't exist" do
        handler_hash = {
          "null_handler" => {
            "commands" => [{
              "description" => 'A nice method',
              "action" => 'doesnt_exist',
              "name" => 'wazzzzzzaaa',
            }],
          },
        }

        exception = assert_raises(Exceptions::InvalidHandler) do
          Validator.verify_handler_integrity(handler_hash)
        end
        assert_equal "null_handler is not defined", exception.message
      end
    end
  end
end
