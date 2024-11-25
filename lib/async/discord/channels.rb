require_relative "representation"

module Async
	module Discord
		class Message < Representation
		end
		
		class Channel < Representation
			def send_message(content)
				payload = {
					content: content
				}
				
				Message.post(@resource.with(path: "messages"), payload)
			end
			
			def id
				self.value[:id]
			end
			
			def text?
				self.value[:type] == 0
			end
			
			def voice?
				self.value[:type] == 2
			end
		end
		
		class Channels < Representation
			def each(&block)
				return to_enum unless block_given?
				
				self.value.each do |value|
					path = "/api/v10/channels/#{value[:id]}"
					
					yield Channel.new(@resource.with(path: path), value: value)
				end
			end
			
			def to_a
				each.to_a
			end
		end
	end
end
