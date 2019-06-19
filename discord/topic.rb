module Topic
  extend Discordrb::Commands::CommandContainer

  command(:topic, description: "Updates the current Discord channel's topic to match the connected IRC channel's. Also displays channel modes.") do |event|
    modes = []
    m = Irc.Channel("\##{event.channel.name}")
    m.modes.each do |e, _f|
      modes.push e
    end
    event.channel.topic = "[+#{modes.join('')}] #{m.topic.gsub(/([0-9][0-9]|[0-9])/, '')}"
    event.respond "Synced this channel's topic!"
  end
end
