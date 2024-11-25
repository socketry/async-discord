# frozen_string_literal: true

require_relative "lib/async/discord/version"

Gem::Specification.new do |spec|
	spec.name = "async-discord"
	spec.version = Async::Discord::VERSION
	
	spec.summary = "Build Discord bots and use real time messaging."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/async-discord"
	
	spec.metadata = {
		"source_code_uri" => "https://github.com/socketry/async-discord.git",
	}
	
	spec.files = Dir.glob(["{.github,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "async-rest", "~> 0.12"
	spec.add_dependency "async-websocket", "~> 0.13"
end
