# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

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

	with "#current_application" do
		it "can get the current application" do
			application = client.current_application

			expect(application).to be_a(Async::Discord::Application)
			expect(application.id).to be_kind_of(Integer)
		end
	end
end
