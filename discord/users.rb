module Users
  extend Discordrb::Commands::CommandContainer

  command(:users, description: "Get a list of users in the current channel") do |event|
    channel = Irc.Channel("\##{event.channel.name}")
    users = channel.users.keys.join(' ').split(' ')
    modes = []
    channel.users.each { |e| modes[modes.length] = e[1] }

    opers = []
    owners = []
    admins = []
    ops = []
    halfops = []
    voiced = []
    member = []

    (0..modes.length - 1).each do |i|
      mod = modes[i]
      if mod.length.zero?
        member[member.length] = users[i]
        next
      end
      mod = [mod[0]] if mod.length > 1
      mod = mod[0]
      opers.push(users[i]) if mod == 'Y'
      owners.push(users[i]) if mod == 'q'
      admins.push(users[i]) if mod == 'a'
      ops.push(users[i]) if mod == 'o'
      halfops.push(users[i]) if mod == 'h'
      voiced.push(users[i]) if mod == 'v'
    end
    event.channel.send_embed do |embed|
      embed.title = "Users in \##{event.channel.name}"
      embed.colour = 0xe7cf31

      embed.add_field(name: '!Opers', value: opers.join(', '), inline: true) unless owners.length.zero?
      embed.add_field(name: '~Owners', value: owners.join(', '), inline: true) unless owners.length.zero?
      embed.add_field(name: '&Admins', value: admins.join(', '), inline: true) unless admins.length.zero?
      embed.add_field(name: '@Ops', value: ops.join(', '), inline: true) unless ops.length.zero?
      embed.add_field(name: '%Halfops', value: halfops.join(', '), inline: true) unless halfops.length.zero?
      embed.add_field(name: '+Voiced', value: voiced.join(', '), inline: true) unless voiced.length.zero?
      embed.add_field(name: 'Member', value: member.join(', '), inline: true) unless member.length.zero?
    end
  end
end
