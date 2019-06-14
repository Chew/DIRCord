module Hooks
  extend Discordrb::Commands::CommandContainer

  command(:setupwebhook, description: "Creates a webhook for this channel. All messages will be sent as webhooks.") do |event|
    if event.channel.webhooks.empty?
      data = Discordrb::API::Channel.create_webhook(Discord.token, event.channel.id, "#{event.channel.name} hook!", reason: "DIRCord hook for #{event.channel.name}")
      hook = Discordrb::Webhook.new(JSON.parse(data), Discord)

      client = Discordrb::Webhooks::Client.new(url: "https://canary.discordapp.com/api/webhooks/#{hook.id}/#{hook.token}")
      client.execute do |builder|
        builder.content = "Testing the new webhook system! Looks good :)"
        builder.username = "[DIRCord]"
      end
    end
  end
end
