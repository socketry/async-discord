# frozen_string_literal: true

require "async/discord/client"
require "sus/fixtures/async/reactor_context"

module Async
	module Discord
		DISCORD_BOT_TOKEN = ENV.fetch("DISCORD_BOT_TOKEN")
		
		ClientContext = Sus::Shared("client context") do
			include Sus::Fixtures::Async::ReactorContext
			
			def authenticated_client
				client = Async::Discord::Client.open
				
				return client.authenticated(bot: DISCORD_BOT_TOKEN)
			end
			
			let(:client) {authenticated_client}
		end
	end
end
