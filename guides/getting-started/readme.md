# Getting Started

This guide explains how to create a bot for Discord using the `async-discord` gem.

## Installation

First, create a project with a gemfile, and add the `async-discord` gem to it:

```bash
$ bundle add async-discord
```

## Creating a Bot

You will need to follow the [developer documentation](https://discord.com/developers/docs/intro) to create a bot and obtain a token. Once you have a token, you can create a bot like this:

```ruby
require 'async/discord'

TOKEN = 'your-bot-token'

Async::Discord::Client.open do |client|
	client = client.authenticated(bot: TOKEN)
	
	client.gateway.connect do |connection|
		identity = connection.identify(token: TOKEN)
		
		connection.listen do |payload|
			case payload[:t]
			when "MESSAGE_CREATE"
				Console.info(self, "Received message!", payload: payload)
			end
		end
	end
end
```

This code will connect to the Discord gateway and listen for messages. When a message is received, it will log the payload to the console. You must make sure your bot is set up with the correct permissions to receive messages.
