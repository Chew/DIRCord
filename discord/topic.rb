module Topic
  extend Discordrb::Commands::CommandContainer

  command(:topic) do |event|
    modes = []
    m = Irc.Channel("\##{event.channel.name}")
    m.modes.each do |e, _f|
      modes.push e
    end
    event.channel.topic = "[+#{modes.join('')}] #{m.topic.gsub(/([0-9][0-9]|[0-9])/, '')}"
    event.respond "Synced this channel's topic!"
  end
end
