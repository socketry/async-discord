# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative "representation"

require_relative "guilds"
require_relative "gateway"

module Async
	module Discord
		class Client < Async::REST::Resource
			ENDPOINT = Async::HTTP::Endpoint.parse("https://discord.com/api/v10/")
			USER_AGENT = "#{self.name} (https://github.com/socketry/async-discord, v#{Async::Discord::VERSION})"
			
			def authenticated(bot: nil, bearer: nil)
				headers = {}
				
				headers["user-agent"] ||= USER_AGENT
				
				if bot
					headers["authorization"] = "Bot #{bot}"
				elsif bearer
					headers["authorization"] = "Bearer #{bearer}"
				else
					raise ArgumentError, "You must provide either a bot or bearer token!"
				end
				
				return self.with(headers: headers)
			end
			
			def guilds
				Guilds.new(self.with(path: "users/@me/guilds"))
			end
			
			def gateway
				Gateway.new(self.with(path: "gateway/bot"))
			end
			
			def channel(id)
				Channel.new(self.with(path: "channels/#{id}"))
			end
		end
	end
end
