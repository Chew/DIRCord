module Topic
  extend Discordrb::Commands::CommandContainer

  command(:topic) do |event|
    modes = []
    m = Irc.Channel("\##{event.channel.name}")
    m.modes.each do |e, _f|
      modes[modes.length] = e
    end
    event.channel.topic = "[+#{modes.join('')}] #{m.topic.gsub!(/([0-9][0-9]|[0-9])/, '')}"
    event.respond 'Set the channel topic!'
  end
end
