# frozen_string_literal: true

module Async
	module Discord
		# Represents an application command.
		class ApplicationCommand < Representation
			# The unique identifier for this application command.
			def id
				self.value[:id]
			end

			# The name of this application command.
			def name
				self.value[:name]
			end

			# Update this application command.
			def update(payload)
				self.class.patch(@resource, payload)
			end

			# Delete this application command.
			def delete
				self.class.delete(@resource)
			end
		end

		# Represents a collection of application commands.
		class ApplicationCommands < Representation
			# Create a new application command.
			def create(payload)
				ApplicationCommand.post(@resource, payload)
			end

			# Enumerate over each command.
			def each(&block)
				return to_enum unless block_given?

				self.value.each do |value|
					yield ApplicationCommand.new(@resource.with(path: value[:id]), value: value)
				end
			end
		end
	end
end
