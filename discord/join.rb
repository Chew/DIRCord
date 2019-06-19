module Join
  extend Discordrb::Commands::CommandContainer

  command(:join, min_args: 0, max_args: 2, description: "Joins a channel on IRC, and creates a channel on Discord if a channel doesn't already exist.") do |event, channel = nil, pass = nil|
    if channel.nil?
      channel = event.channel.name
    elsif channel.include?('<') && channel.split('>').length == 1
      channel = Discord.channel(channel.to_i).name
    elsif channel.include?('#')
      channel = channel[1..channel.length]
    end
    Irc.Channel("\##{channel} #{pass}").join
    event.respond '*Joined the channel successfully!*'
  end
end
