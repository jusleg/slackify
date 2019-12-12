## V0.2.0

Update `custom_event_subtype_handlers` to `custom_message_subtype_handlers` and add support for `custom_event_type_handlers`. This is a breaking change since we rename the field that was previously used. To fix, update any calls from `custom_event_subtype_handlers` to `custom_message_subtype_handlers` and you should be good to go.

## V0.1.5

Update how the `bot_id` is set in the handler configuration. You can disable the slack auth test (which is used to obtain the bot_id) by setting `SLACK_AUTH_SKIP=1` in your environment variables. If you are running in a Rails environment other than production, development or staging and would like to use the bot for real requests, you can trigger a manual auth test by calling `Slackify.configuration.handlers.bot_auth_test`. Gemfile.lock was removed.

## V0.1.4

Custom unhandled_handler configuration fix. It wouldn't let you set a custom one as the validation was checking for `is_a?` instead of `<`

## V0.1.3
Added `remove_unhandled_handler` as a configuration option to disable the unhandled handler.

## V0.1.2

* Renaming the gem from toddlerbot to slackify.
* Cleanup of `lib/slackify` folder.
* Added a new configuration: unhandled_handler. You can specify a subclass of `Slackify::Handlers::Base` in the config. This class will be called with `#unhandled` when a message has no regex match.

## V0.1.1

Fix constantize vulnerability in the slack controller by introducing supported handler through `#inherited` or `Toddlerbot::BaseHandler`.

## V0.1.0

First release. Everything is new.
