# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative "representation"

require_relative "guilds"
require_relative "gateway"
require_relative "application"

module Async
	module Discord
		# A client for interacting with Discord.
		class Client < Async::REST::Resource
			# The default endpoint for Discord.
			ENDPOINT = Async::HTTP::Endpoint.parse("https://discord.com/api/v10/")

			# The default user agent for this client.
			USER_AGENT = "#{self.name} (https://github.com/socketry/async-discord, v#{Async::Discord::VERSION})"

			# Authenticate the client, either with a bot or bearer token.
			#
			# @parameter bot [String] The bot token.
			# @parameter bearer [String] The bearer token.
			# @returns [Client] a new client with the given authentication.
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

			# @returns [Guilds] a collection of guilds the bot is a member of.
			def guilds
				Guilds.new(self.with(path: "users/@me/guilds"))
			end

			# @returns [Gateway] the gateway for the bot.
			def gateway
				Gateway.new(self.with(path: "gateway/bot"))
			end

			# @returns [Channel] a channel by its unique identifier.
			def channel(id)
				Channel.new(self.with(path: "channels/#{id}"))
			end

			# @returns [Application] the application.
			def application(id)
				Application.new(self.with(path: "applications/#{id}"))
			end

			# @returns [Application] the application which is currently authenticated.
			def current_application
				application("@me")
			end
		end
	end
end
