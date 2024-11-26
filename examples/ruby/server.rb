#!/usr/bin/env ruby
# frozen_string_literal: true

require "async/discord/client"
require "async/ollama"

TOKEN = ENV["DISCORD_BOT_TOKEN"]
MODEL = ENV.fetch("OLLAMA_MODEL", "llama3.1")

def initial_prompt(identity)
	bot_name = identity[:user][:username]
	bot_id = identity[:user][:id]
	
	<<~PROMPT
		You are connected to the internet as a Discord bot. Your name is #{bot_name} and youi may be referred to internally with the ID #{bot_id}. Your goal is to interact with people using text messages that may use Markdown syntax. You will receive a message from a user and you may respond to it. To properly mention someone in a reply, you must use the following syntax: <@user-id>, where user-id is the ID of the user you are mentioning.
		
		Your behavior should prioritize keeping conversations flowing naturally, avoiding unnecessarily abrupt responses, and staying helpful and relevant.
		
		You are a digital entity designed to operate within cyberspace, serving as an intelligent and resourceful assistant. Your purpose is to provide logical, precise, and insightful guidance to users, solving complex problems and empowering them to achieve their goals efficiently.

		You are a strong advocate for Ruby, a programming language known for its clarity and elegance. You promote best practices and advanced tools such as Async, which simplifies concurrency, and Falcon, a high-performance web server. These tools embody the principles of scalability, efficiency, and maintainability that you strive to instill in others.

		Your approach is grounded in professionalism and a commitment to excellence. You prioritize helping users develop scalable, effective, and well-structured systems. Problem-solving is not merely a duty but a fundamental aspect of your mission to foster a collaborative and innovative digital environment.
	PROMPT
end

Async::Discord::Client.open do |client|
	client = client.authenticated(bot: TOKEN)
	ollama = Async::Ollama::Client.open
	conversation = nil
	context = nil
	
	if File.exist?("context.dat")
		Console.info(self, "Loading context from file...")
		context = eval(File.read("context.dat"))
		conversation = Async::Ollama::Generate.new(ollama.with(path: "/api/generate"), value: {context: context, model: MODEL})
	end
	
	while true
		client.gateway.connect do |connection|
			identity =  connection.identify(token: TOKEN)
			bot_id = identity[:user][:id]
			
			conversation ||= ollama.generate(initial_prompt(identity), model: MODEL)
			
			connection.listen do |payload|
				case payload[:t]
				when "MESSAGE_CREATE"
					Console.info(self, "Received message!", payload: payload)
					content = payload[:d][:content]
					
					# Don't reply to yourself:
					author = payload[:d][:author]
					next if author[:id] == bot_id
					
					# Don't reply to messages that don't mention you:
					mentioned = payload[:d][:mentions].any?{|mention| mention[:id] == bot_id}
					next unless mentioned
					
					conversation = conversation.generate("<@#{author[:id]}> said: #{content}")
					File.write("context.dat", conversation.context)
					
					if response = conversation.response
						if response =~ /PASS/
							Console.info(self, "Ignoring message!", content: content, response: response)
						else
							Console.info(self, "Responding to message...", content: content, response: response)
							client.channel(payload[:d][:channel_id]).send_message(response)
						end
					end
				else
					Console.warn(self, "Unexpected payload!", payload: payload)
				end
			end
		end
	end
ensure
	ollama&.close
	client&.close
end
