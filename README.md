# Slackify [![Build Status](https://travis-ci.org/jusleg/slackify.svg?branch=master)](https://travis-ci.org/jusleg/slackify) [![Gem Version](https://badge.fury.io/rb/slackify.svg)](https://badge.fury.io/rb/slackify)

Slackify is a gem that allows to build slackbots on Rails using the [Event API](https://api.slack.com/events-api) from Slack.

## Table of Contents
* [How does it work](#how-does-it-work)
  * [Handlers](#handlers)
    * [Plain messages](#handling-plain-messages)
    * [Interactive messages](#handling-interactive-messages)
    * [Slash Command](#handling-slash-commands)
    * [Custom handler for event subtypes](#custom-handler-for-event-subtypes)
  * [Slack client](#slack-client)
    * [Sending a simple message](#sending-a-simple-message)
    * [Sending an interactive message](#sending-an-interactive-message)
  * [Slack 3 second reply window](#slack-3-seconds-reply-window)
* [How to run your own slackify](#how-to-run-your-own-slackify)
  * [Initial Setup](#initial-setup)
  * [Slack Setup](#slack-setup)

# How does it work
The core logic of the bot resides in its handlers. When the app starts, a list of handler gets initialized from a config file (`config/handlers.yml`). This initializes all the plain message handlers. Out of the box, the application supports three types of events

1. [Plain messages](#handling-plain-messages)
2. [Interactive messages](#handling-interactive-messages)
3. [Slash Command](#handling-slash-commands)

## Handlers
### Handling plain messages
These are the basic handlers. They use a regex to identify if they should be called. When a message event gets sent to the bots, the slack controller sends the message to the list of handlers. The message will be checked against the regex of every handler until there is a match. When there is a match, the handler will get called with all the parameters provided by slack. If no handler matches the command, the unhandled handler will be called instead.

Those handlers are configured via the `config/handlers.yml` configuration file. Let's dissect the configuration of a handler.

```yaml
-
  repeat_handler:
    commands:
      -
        name: Repeat
        description: "`repeat [sentence]`: Repeats the sentence you wrote"
        regex: !ruby/regexp '/^repeat (?<sentence>.+)/i'
        action: repeat
```

The ruby class `repeat_handler.rb` would look something like this:

```ruby
class RepeatHandler < Slackify::Handlers::Base
  class << self
    def repeat(params)
      slack_client.chat_postMessage(
        as_user: true,
        channel: params[:event][:user],
        text: "you just said: #{params[:command_arguments][:sentence]}",
      )
    end
  end
end
```

`config/handlers.yml` is configured to be an array of handlers. This examples only shows one handler. The top level key refers to the name of the handler in snake_case. In this case `repeat_handler` refers to RepeatHandler. This handler can handle multiple commands. In our example, it only handles one command: repeat. A command is defined by a `name`, `description`, `regex` and `action`. The name and description are more there to allow you to implement a custom help handler that would display all the commands. The core part is the regex and the action. If the regex match, the action is the method that will be called in the handler. In this example, if the regex matches, we'll call `RepeatHandler#repeat`.

To add a new handler, you can add a new file under `app/handlers/` and start adding new commands. You will also need to update the `config/handlers.yml` configuration to register the command.

**Note:** The regex supports [named capture](https://www.regular-expressions.info/named.html). In this example, we have a name example of `sentence`. When the handler command will be called, a key in the parameter hash will be added: `command_arguments`. This key will point to a hash of the capture name and value. In this case, `command_arguments => {sentence: "the sentence you wrote"}`

### Handling interactive messages
When sending an interactive message to a user, slack let's you define the `callback_id`. The app uses the callback id to select the proper handler for the message that was sent. The callback id must follow the given format: `class_name#method_name`. For instance if you set the callback id to `repeat_handler#repeat`, then `RepeatHandler#repeat` will be called. Adding new handlers does not require to update the `config/handlers.yml` configuration. You only need to update the callback id to define the proper handler to be used when you send an interactive message.

### Handling slash commands
The code also has an example of a slash command and its handler (`slash_handler.rb`). To add a command on the bot, head to you app configuration on https://api.slack.com/apps and navigate to Slack Commands using the sidebar. Create a new one. The important part is to set the path properly. To bind with the demo handler, you would need to setup the path like this: `/slackify/slash/slash_handler/example_slash`. The format is `/slackify/slash/[handler_name]/[action_name]`. An app shouldn't have many slash commands. Keep in mind that adding a slash command means that the whole organization will see it.

You will need to whitelist the method in the handler to indicate it can be used as a slash command using `allow_slash_method`

```ruby
class DummyHandler < Slackify::Handlers::Base
  allow_slash_method :slash_command

  class << self
    
    def slash_command(_params)
      "dummy_handler slash_command() was called"
    end
  end
end
```

### Custom handler for event subtypes

If you wish to add more functionalities to your bot, you can specify define new behaviours for different event subtypes. You can specify a hash with the event subtype as a key and the handler class as the value. Slackify will call `.handle_event` on your class and pass the controller params as parameters.

```ruby
Slackify.configuration.custom_event_subtype_handlers = {
  file_share: ImageHandler
}
```

In this example, all events of subtype `file_share` will be sent to the `ImageHandler` class.

## Slack client
In order to send messages, the [slack ruby client gem](https://github.com/slack-ruby/slack-ruby-client) was used. You can send plain text messages, images and interactive messages. Since the bot was envisioned being more repsonsive than proactive, the client was made available for handlers to call using the `slack_client` method. If you wish to send messages outside of handlers, you can get the slack client by calling `Slackify.configuration.slack_client`

### Sending a simple message
```ruby
slack_client.chat_postMessage(channel: 'MEMBER ID OR CHANNEL ID', text: 'Hello World', as_user: true)
```

### Sending an interactive message
```ruby
slack_client.chat_postMessage(
  channel: 'MEMBER ID OR CHANNEL ID', 
  as_user: true, 
  attachments: [{
    "fallback": "Would you recommend it to customers?",
    "title": "Would you recommend it to customers?",
    "callback_id": "repeat_handler#repeat",
    "color": "#3AA3E3",
    "attachment_type": "default",
    "actions": [
      {
        "name": "recommend",
        "text": "Recommend",
        "type": "button",
        "value": "recommend"
      },
      {
        "name": "no",
        "text": "No",
        "type": "button",
        "value": "No"
      }
    ]
  }]
)
```

## Slack 3 seconds reply window
Slack introduced a [3 seconds reply window](https://api.slack.com/messaging/interactivity#response) for interactive messages. That means that if you reply to an interactive message or slash command event with a json, slack will show either update the attachment or send a new one without having to use `chat_postMessage`. If you wish to use this feature with Slackify, you only need to return either a json of an attachment or a plain text string when you handler method is called. **Your method should always return `nil` otherwise**.

# How to run your own slackify
## Initial Setup
1. Install slackify in your app by adding the following line in your `Gemfile`:

```ruby
gem "slackify"
```

2. run the following command in your terminal:

```console
bundle install
```

3. Add handlers to your application. Remember to make them extend `Slackify::Handlers::Base`

4. Create a `config/handlers.yml` file and define your triggers for specific commands.

5. [Proceed to connect your bot to slack](#slack-setup)


## Slack Setup
First, you'll need to create a new app on slack. Head over to [slack api](https://api.slack.com/apps) and create a new app.

1. **Set Slack Secret Token**

    In order to verify that the requets are coming from slack, we'll need to set the slack secret token in slackify. This value can be found as the signing secret in the app credentials section of the basic information page.

2. **Add a bot user**
  
    Under the feature section, click on "bot users". Pick a name for you slack bot and toggle on "Always Show My Bot as Online". Save the setting.

3. **Enable events subscription**

    Under the feature section, click "Events subscription". Turn the feature on and use your app url followed by `/slackify/event`. [Ngrok](https://ngrok.com/) can easily get you a public url if you are developing locally. The app needs to be running when you configure this url. After the url is configured, under the section "Subscribe to Bot Events", add the bot user event `message.im`.

4. **Activate the interactive components**
  
    Under the feature section, click "interactive components". Turn the feature on and use your ngrok url followed by `/slackify/interactive`. Save the setting.

5. **Install the App**

    Under the setting section, click "install app" and proceed to install the app to the workspace. Once the app is installed, go back to the "install app" page and copy the Bot User OAuth Access Token.

6. **Configure Slackify**
```ruby
Slackify.configure do |config|
  config.slack_bot_token = "xoxb-sdkjlkjsdflsd..."
  config.slack_secret_token = "1234dummysecret"
end
```

7. **Add an initializer**
```ruby
# config/initializers/slackify.rb
Slackify.load_handlers
```

8. **Define handlers specific subtypes** (Optional)

```ruby
# config/initializers/slackify.rb
Slackify.load_handlers
Slackify.configuration.custom_event_subtype_handlers = {
  file_share: ImageHandler,
  channel_join: JoinHandler,
  ...
}
```

**At this point, you are ready to go 😄**


# LICENSE
Copyright (c) 2019 Justin Léger, Michel Chatmajian. See [LICENSE](https://github.com/jusleg/slackify/blob/master/LICENSE) for further details.
