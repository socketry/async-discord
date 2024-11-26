# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative "representation"

module Async
	module Discord
		# Represents a message in a channel.
		class Message < Representation
		end
		
		# Represents a channel in a guild.
		class Channel < Representation
			# Send a message to this channel.
			#
			# @parameter content [String] The content of the message.
			def send_message(content)
				payload = {
					content: content
				}
				
				Message.post(@resource.with(path: "messages"), payload)
			end
			
			# The unique identifier for this channel.
			def id
				self.value[:id]
			end
			
			# Whether this channel is a text channel.
			#
			# @returns [Boolean] if this channel is a text channel.
			def text?
				self.value[:type] == 0
			end
			
			# Whether this channel is a voice channel.
			#
			# @returns [Boolean] if this channel is a voice channel.
			def voice?
				self.value[:type] == 2
			end
		end
		
		# Represents a collection of channels.
		class Channels < Representation
			# Enumerate over each channel.
			#
			# @yields {|channel| ...}
			# 	@parameter channel [Channel] The channel.
			def each(&block)
				return to_enum unless block_given?
				
				self.value.each do |value|
					path = "/api/v10/channels/#{value[:id]}"
					
					yield Channel.new(@resource.with(path: path), value: value)
				end
			end
			
			# Convert this collection to an array.
			#
			# @returns [Array(Channel)] an array of channels.
			def to_a
				each.to_a
			end
		end
	end
end
