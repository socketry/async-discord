require_relative "representation"
require_relative "channels"

module Async
	module Discord
		class Guild < Representation
			def channels
				Channels.new(@resource.with(path: "channels"))
			end
			
			def id
				self.value[:id]
			end
		end
		
		class Guilds < Representation
			def each(&block)
				return to_enum unless block_given?
				
				self.value.each do |value|
					path = "/api/v10/guilds/#{value[:id]}"
					
					yield Guild.new(@resource.with(path: path), value: value)
				end
			end
			
			def to_a
				each.to_a
			end
			
			def empty?
				self.value.empty?
			end
		end
	end
end
