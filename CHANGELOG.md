## V0.1.2

* Renaming the gem from toddlerbot to slackify.
* Cleanup of `lib/slackify` folder.
* Added a new configuration: unhandled_handler. You can specify a subclass of `Slackify::Handlers::Base` in the config. This class will be called with `#unhandled` when a message has no regex match.

## V0.1.1

Fix constantize vulnerability in the slack controller by introducing supported handler through `#inherited` or `Toddlerbot::BaseHandler`.

## V0.1.0

First release. Everything is new.
