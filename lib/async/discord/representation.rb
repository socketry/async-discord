# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest/representation"
require "async/rest/wrapper/form"

module Async
	module Discord
		class Wrapper < Async::REST::Wrapper::JSON
		end
		
		class Representation < Async::REST::Representation[Wrapper]
		end
	end
end
