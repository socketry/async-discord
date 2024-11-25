# frozen_string_literals: true
#
# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'representation'

require_relative 'guilds'
require_relative 'gateway'

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
