# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative "representation"
require_relative "channels"

module Async
	module Discord
		# Represents a guild in Discord.
		class Guild < Representation
			# @returns [Channels] a collection of channels in this guild.
			def channels
				Channels.new(@resource.with(path: "channels"))
			end
			
			# The unique identifier for this guild.
			def id
				self.value[:id]
			end
		end
		
		# Represents a collection of guilds.
		class Guilds < Representation
			# Enumerate over each guild.
			#
			# @yields {|guild| ...} if a block is given.
			# 	@parameter guild [Guild] The guild.
			# @returns [Enumerator] if no block is given.
			def each(&block)
				return to_enum unless block_given?
				
				self.value.each do |value|
					path = "/api/v10/guilds/#{value[:id]}"
					
					yield Guild.new(@resource.with(path: path), value: value)
				end
			end
			
			# Convert the collection to an array.
			#
			# @returns [Array(Guild)] the collection as an array.
			def to_a
				each.to_a
			end
			
			# @returns [Boolean] if the collection is empty.
			def empty?
				self.value.empty?
			end
		end
	end
end
