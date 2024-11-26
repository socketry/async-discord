require "async/discord/client_context"

describe Async::Discord::Client do
	include Async::Discord::ClientContext
	
	with "#guilds" do
		it "can list guilds" do
			guilds = client.guilds
			
			expect(guilds).to be_a(Async::Discord::Guilds)
			expect(guilds).not.to be(:empty?)
		end
	end
end
