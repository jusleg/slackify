## V0.3.3

- Add support for named parameters in commands ([PR #12](https://github.com/jusleg/slackify/pull/12)) by [@DougEdey](https://github.com/DougEdey)
- Add support for custom parameters in commands ([PR #17](https://github.com/jusleg/slackify/pull/17)) by [@DougEdey](https://github.com/DougEdey)
- Tidy up some tests

## V0.3.2

- Add support for interactive block payloads ([b6cf1db](https://github.com/jusleg/slackify/commit/b6cf1dbb47b832037ebff56054efa27c9e3251dc)) by [@drose-shopify](https://github.com/drose-shopify)

## V0.3.0

- Add code documentation and improve exception message
- Add approval of bot ids in the configuration through `allowed_bot_ids=`
- Refactored Handler configuration into `Slackify::Router` and `Slackify::Handlers::Factory`
- Improved testing
- Remove the need to perform `Slackify.load_handler`
- **Breaking change:** Given that we now load the handlers on `Slack.configure`, the configuration step done in `config/application.rb` will have to be done in an initializer to have all the handler class loaded.

## V0.2.0

Update `custom_event_subtype_handlers` to `custom_message_subtype_handlers` and add support for `custom_event_type_handlers`. This is a breaking change since we rename the field that was previously used. To fix, update any calls from `custom_event_subtype_handlers` to `custom_message_subtype_handlers` and you should be good to go.

## V0.1.5

Update how the `bot_id` is set in the handler configuration. You can disable the slack auth test (which is used to obtain the bot_id) by setting `SLACK_AUTH_SKIP=1` in your environment variables. If you are running in a Rails environment other than production, development or staging and would like to use the bot for real requests, you can trigger a manual auth test by calling `Slackify.configuration.handlers.bot_auth_test`. Gemfile.lock was removed.

## V0.1.4

Custom unhandled_handler configuration fix. It wouldn't let you set a custom one as the validation was checking for `is_a?` instead of `<`

## V0.1.3

Added `remove_unhandled_handler` as a configuration option to disable the unhandled handler.

## V0.1.2

- Renaming the gem from toddlerbot to slackify.
- Cleanup of `lib/slackify` folder.
- Added a new configuration: unhandled_handler. You can specify a subclass of `Slackify::Handlers::Base` in the config. This class will be called with `#unhandled` when a message has no regex match.

## V0.1.1

Fix constantize vulnerability in the slack controller by introducing supported handler through `#inherited` or `Toddlerbot::BaseHandler`.

## V0.1.0

First release. Everything is new.
