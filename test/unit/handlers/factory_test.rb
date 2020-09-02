# frozen_string_literal: true

module Slackify
  module Handlers
    class FactoryTest < ActiveSupport::TestCase
      test "#for generates the proper struct" do
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

        handler_struct = Factory.for(handler_hash)

        assert_equal 'dummy_handler', handler_struct.name
        assert_equal 1, handler_struct.commands.count

        handler_command = handler_struct.commands.first

        assert_equal(/wazza/, handler_command.regex)
        assert_equal 'A nice method', handler_command.description
        assert_equal DummyHandler.method(:cool_command), handler_command.handler
      end
    end
  end
end
