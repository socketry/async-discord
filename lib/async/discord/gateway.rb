# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative "representation"

require "async/websocket"

module Async
	module Discord
		# Represents a gateway connection to Discord, which can be used to send and receive messages via a WebSocket connection.
		class GatewayConnection < Async::WebSocket::Connection
			# Gateway Opcodes:
			DISPATCH = 0
			HEARTBEAT = 1
			IDENTIFY = 2
			PRESENCE_UPDATE = 3
			VOICE_STATE_UPDATE = 4
			RESUME = 6
			RECONNECT = 7
			REQUEST_GUILD_MEMBERS = 8
			INVALID_SESSION = 9
			HELLO = 10
			HEARTBEAT_ACK = 11
			REQUEST_SOUNDBOARD_SOUNDS = 31
			
			# Gateway Error Codes.
			ERROR_CODES = {
				4000 => "UNKNOWN_ERROR",
				4001 => "UNKNOWN_OPCODE",
				4002 => "DECODE_ERROR",
				4003 => "NOT_AUTHENTICATED",
				4004 => "AUTHENTICATION_FAILED",
				4005 => "ALREADY_AUTHENTICATED",
				4007 => "INVALID_SEQUENCE",
				4008 => "RATE_LIMITED",
				4009 => "SESSION_TIMEOUT",
				4010 => "INVALID_SHARD",
				4011 => "SHARDING_REQUIRED",
				4012 => "INVALID_VERSION",
				4013 => "INVALID_INTENT",
				4014 => "DISALLOWED_INTENT"
			}
			
			# Guild Intents.
			module Intent
				GUILDS = 1 << 0
				GUILD_MEMBERS = 1 << 1
				GUILD_MODERATION = 1 << 2
				GUILD_EXPRESSIONS = 1 << 3
				GUILD_INTEGRATIONS = 1 << 4
				GUILD_WEBHOOKS = 1 << 5
				GUILD_INVITES = 1 << 6
				GUILD_VOICE_STATES = 1 << 7
				GUILD_PRESENCES = 1 << 8
				GUILD_MESSAGES = 1 << 9
				GUILD_MESSAGE_REACTIONS = 1 << 10
				GUILD_MESSAGE_TYPING = 1 << 11
				DIRECT_MESSAGES = 1 << 12
				DIRECT_MESSAGE_REACTIONS = 1 << 13
				DIRECT_MESSAGE_TYPING = 1 << 14
				MESSAGE_CONTENT = 1 << 15
				GUILD_SCHEDULED_EVENTS = 1 << 16
				AUTO_MODERATION_CONFIGURATION = 1 << 20
				AUTO_MODERATION_EXECUTION = 1 << 21
				GUILD_MESSAGE_POLLS = 1 << 24
				DIRECT_MESSAGE_POLLS = 1 << 25
			end
			
			# Default intent for a bot.
			DEFAULT_INTENT = Intent::GUILDS | Intent::GUILD_MESSAGES | Intent::DIRECT_MESSAGES
			
			# Default properties for a bot.
			DEFAULT_PROPERTIES = {
				os: RUBY_PLATFORM,
				browser: Async::Discord.name,
				device: Async::Discord.name,
			}
			
			# Default presence for a bot.
			DEFAULT_PRESENCE = {
				status: "online",
				afk: false,
				activities: [],
			}
			
			# Initialize the gateway connection.
			def initialize(...)
				super
				
				@heartbeat_task = nil
				@sequence = nil
			end
			
			# Close the gateway connection, including the heartbeat task.
			def close(...)
				if heartbeat_task = @heartbeat_task
					@heartbeat_task = nil
					heartbeat_task.stop
				end
				
				super
			end
			
			# Identify the bot with the given identity.
			#
			# @returns [Hash] the payload from the READY event.
			def identify(**identity)
				while message = self.read
					payload = message.parse
					
					case payload[:op]
					when HELLO
						@heartbeat_task ||= self.run_heartbeat(payload[:d][:heartbeat_interval])
						break
					else
						Console.warn(self, "Unexpected payload during identify: #{payload}")
					end
				end
				
				identity[:intents] ||= DEFAULT_INTENT
				identity[:properties] ||= DEFAULT_PROPERTIES
				identity[:presence] ||= DEFAULT_PRESENCE
				
				Console.debug(self, "Identifying...", identity: identity)
				::Protocol::WebSocket::TextMessage.generate(op: IDENTIFY, d: identity).send(self)
				
				while message = self.read
					payload = message.parse
					
					if payload[:op] == DISPATCH && payload[:t] == "READY"
						Console.info(self, "Identified successfully.")
						
						# Store the sequence number for future heartbeats:
						@sequence = payload[:s]
						
						return payload[:d]
					elsif payload[:op] == INVALID_SESSION
						Console.warn(self, "Invalid session.")
						break
					else
						Console.warn(self, "Unexpected payload during identify: #{payload}")
					end
				end
			end
			
			# Listen for events from the gateway.
			#
			# @yields {|payload| ...}
			# 	@parameter payload [Hash] The parsed payload.
			def listen
				while message = self.read
					payload = message.parse
					
					case payload[:op]
					when DISPATCH
						@sequence = payload[:s]
						yield payload
					when HEARTBEAT
						Console.debug(self, "Received heartbeat request.", payload: payload)
						heartbeat_message = ::Protocol::WebSocket::TextMessage.generate(op: HEARTBEAT_ACK, d: @sequence)
						heartbeat_message.send(self)
					when HEARTBEAT_ACK
						Console.debug(self, "Received heartbeat ACK.", payload: payload)
					else
						yield payload
					end
				end
			end
			
			private
			
			# Run a heartbeat task at the given interval.
			def run_heartbeat(duration_ms)
				duration = duration_ms / 1000.0
				Console.debug(self, "Running heartbeat every #{duration} seconds.")
				
				Async do |task|
					sleep(duration * rand)
					
					while !self.closed?
						Console.debug(self, "Sending heartbeat.", sequence: @sequence)
						heartbeat_message = ::Protocol::WebSocket::TextMessage.generate(op: HEARTBEAT, d: @sequence)
						heartbeat_message.send(self)
						self.flush
						
						sleep(duration)
					end
				end
			end
		end
		
		# Represents a gateway for the bot.
		class Gateway < Representation
			# The URL of the gateway, used for connecting to the WebSocket server.
			def url
				self.value[:url]
			end
			
			# The number of shards to use.
			def shards
				self.value[:shards]
			end
			
			# Limits associated with this bot connecting to the gateway. You should respect these limits to avoid being rate limited.
			#
			# @returns [Hash] the limits, including `:total`, `:remaining`, `:reset_after`, and `:max_concurrency`.
			def session_start_limit
				self.value[:session_start_limit]
			end
			
			# Connect to the gateway, yielding the connection.
			#
			# @yields {|connection| ...} if a block is given.
			# 	@parameter connection [GatewayConnection] The connection to the gateway.
			# @returns [GatewayConnection] the connection to the gateway.
			def connect(shard: nil, &block)
				endpoint = Async::HTTP::Endpoint.parse(self.url, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)
				
				Console.info(self, "Connecting to gateway...", endpoint: endpoint)
				Async::WebSocket::Client.connect(endpoint, handler: GatewayConnection, &block)
			end
		end
	end
end
