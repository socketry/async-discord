# frozen_string_literal: true

require_relative "representation"
require_relative "application_commands"

module Async
	module Discord
		# Represents an application.
		class Application < Representation
			# The unique identifier for this application.
			def id
				self.value[:id]
			end

			# The name of this application.
			def name
				self.value[:name]
			end

			# The global commands for this application.
			def commands
				path = @resource.path.gsub("@me", id) + "/commands"
				ApplicationCommands.new(@resource.with(path: path))
			end
		end
	end
end
