class About
  include Cinch::Plugin

  listen_to :channel, method: :send
  listen_to :connect, method: :identify
  # listen_to :leaving, method: :leave
  listen_to :catchall, method: :net
  listen_to :private, method: :dm

  def identify(_m)
    User('NickServ').send("identify #{CONFIG['nickservpass']}") unless CONFIG['nickservpass'].nil? || CONFIG['nickservpass'] == ''
    Irc.oper(CONFIG['operpass'], CONFIG['operusername']) unless CONFIG['operpass'].nil? || CONFIG['operpass'] == '' || CONFIG['operusername'].nil? || CONFIG['operusername'] == ''
  end

  def join(nick, user, host, channel)
    channel = channel[1..channel.length]
    begin
      dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == 'Direct Messages' }.id
    rescue NoMethodError
      dm_category = Discord.server(CONFIG['server_id']).create_channel('Direct Messages', 4, reason: 'New DM').id
    end
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase && chane.parent_id != dm_category }.id
    message = format('*→ %s joined (%s@%s)*', nick, user, host)
    Discord.channel(chan).send(message)
  end

  def leave(m, user)
    channel = m.channel.to_s[1..m.channel.to_s.length]
    begin
      dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == 'Direct Messages' }.id
    rescue NoMethodError
      dm_category = Discord.server(CONFIG['server_id']).create_channel('Direct Messages', 4, reason: 'New DM').id
    end
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase && chane.parent_id != dm_category }.id
    message = format('*⇐ %s left (%s)*', user, user.host)
    Discord.channel(chan).send(message)
    # else
    # message = format(' %s (%s) quit.', user, user.host)
  end

  def part(nick, user, host, channel, reason)
    channel = channel[1..channel.length]
    begin
      dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == 'Direct Messages' }.id
    rescue NoMethodError
      dm_category = Discord.server(CONFIG['server_id']).create_channel('Direct Messages', 4, reason: 'New DM').id
    end
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase && chane.parent_id != dm_category }.id
    message = format('*⇐ %s left (%s@%s) %s*', nick, user, host, reason)
    Discord.channel(chan).send(message)
  end

  def mode(changed, bywho, modes, channel)
    channel = channel[1..channel.length]
    begin
      dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == 'Direct Messages' }.id
    rescue NoMethodError
      dm_category = Discord.server(CONFIG['server_id']).create_channel('Direct Messages', 4, reason: 'New DM').id
    end
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase && chane.parent_id != dm_category }.id
    message = format('*%s changed modes +%s on %s*', changed, modes, bywho)
    Discord.channel(chan).send(message)
  end

  def quit(nick, user, host, channel, reason)
    channel = channel[1..channel.length]
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase }.id
    message = format('*⇐ %s quit (%s@%s) %s*', nick, user, host, reason)
    Discord.channel(chan).send(message)
  end

  def dm(m)
    begin
      dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == 'Direct Messages' }.id
    rescue NoMethodError
      dm_category = Discord.server(CONFIG['server_id']).create_channel('Direct Messages', 4, reason: 'New DM').id
    end

    begin
      dm_channel = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == m.user.nick.downcase && chane.parent_id == dm_category }.id
    rescue NoMethodError
      dm_channel = Discord.server(CONFIG['server_id']).create_channel(m.user.nick.downcase, 0, parent: dm_category, reason: "New DM from #{m.user.nick}").id
    end

    message = m.message

    message.gsub!(CONFIG['nickname'], "<@#{CONFIG['user_id']}>")
    last = 'none'
    msg = message.split('')
    edited = msg
    i = 0
    msg.each do |char|
      if char == "\u0002"
        puts 'bold found!'
        edited[i] = '**'
        i += 1
        last = 'bold'
      end
      if char == "\u001D"
        puts 'italics found!'
        edited[i] = '*'
        last = 'italic'
      end
      if char == "\u001F"
        puts 'underline found!'
        edited[i] = '__'
        i += 1
        last = 'uline'
      end
      if char == "\u000F"
        puts 'reset char found!'
        case last
        when 'bold'
          edited[i] = '**'
          i += 1
        when 'italic'
          edited[i] = '*'
        when 'uline'
          edited[i] = '__'
          i += 1
        end
      end
      i += 1
    end
    message = edited.join('')
    puts message
    message.gsub!(/([0-9]\d{0,2})/, '')

    Discord.channel(dm_channel).send(message)
  end

  def send(m)
    return if Time.now.to_i - STARTTIME.to_i == 10

    channel = m.channel.to_s[1..m.channel.to_s.length]
    name = m.user.name
    message = m.message
    user = m.user.user

    irccloud = user.match?(/(s|u)id(.+)/)
    id = user.gsub(/(s|u)id/, '').to_i if irccloud

    begin
      dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == 'Direct Messages' }.id
    rescue NoMethodError
      dm_category = Discord.server(CONFIG['server_id']).create_channel('Direct Messages', 4, reason: 'New DM').id
    end
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase && chane.parent_id != dm_category }.id

    message.gsub!(CONFIG['nickname'], "<@#{CONFIG['user_id']}>")
    message.gsub!(CONFIG['nickname'], "<@#{CONFIG['user_id']}>")
    last = 'none'
    msg = message.split('')
    edited = msg
    i = 0
    msg.each do |char|
      if char == "\u0002"
        puts 'bold found!'
        edited[i] = '**'
        i += 1
        last = 'bold'
      end
      if char == "\u001D"
        puts 'italics found!'
        edited[i] = '*'
        last = 'italic'
      end
      if char == "\u001F"
        puts 'underline found!'
        edited[i] = '__'
        i += 1
        last = 'uline'
      end
      if char == "\u000F"
        puts 'reset char found!'
        case last
        when 'bold'
          edited[i] = '**'
          i += 1
        when 'italic'
          edited[i] = '*'
        when 'uline'
          edited[i] = '__'
          i += 1
        end
      end
      i += 1
    end
    message = edited.join('')
    message.gsub!(/([0-9]\d{0,2})/, '')
    message.gsub!("\u0003", '')

    if CONFIG['highlights'].nil?
      CONFIG['highlights'] = ''
      File.open(CONFIG_FILE, 'w') { |f| f.write CONFIG.to_yaml }
    end

    CONFIG['highlights'].split(',').each do |word|
      if message.include?(word)
        message = "[HW <@#{CONFIG['user_id']}>] #{message}"
        break
      end
    end

    if Discord.channel(chan).webhooks.empty?
      Discord.channel(chan).send("**<#{name}>** #{message}")
    else
      hook = Discord.channel(chan).webhooks[0]
      client = Discordrb::Webhooks::Client.new(url: "https://canary.discordapp.com/api/webhooks/#{hook.id}/#{hook.token}")
      client.execute do |builder|
        builder.content = message
        builder.username = name
        builder.avatar_url = "https://static.irccloud-cdn.com/avatar-redirect/#{id}" if irccloud
      end
    end
  end

  def net(m)
    content = m.raw
    data = content.split(' ')
    userhost = data[0][1..-1]
    command = data[1]
    channel = data[2].delete(':')
    reason = data[3]
    reason = reason[1..reason.length] unless reason.nil?
    disc = channel[1..channel.length].downcase
    uh = userhost.split(/!|@/)
    nick = uh[0]
    user = uh[1]
    host = uh[2]
    if command == 'JOIN' && nick != CONFIG['nickname']
      join(nick, user, host, channel)
      return
    end
    if command == 'QUIT' && nick != CONFIG['nickname']
      quit(nick, user, host, channel, reason)
      return
    end
    if command == 'PART' && nick != CONFIG['nickname']
      part(nick, user, host, channel, reason)
      return
    end
    if command == 'MODE' && data[4] != CONFIG['nickname']
      mode(nick, data[4], reason, channel)
      return
    end
    if command == 'JOIN' && nick == CONFIG['nickname']
      chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == disc }
      Discord.server(CONFIG['server_id']).create_channel(channel.downcase) if chan.nil?
      join(nick, user, host, channel)
    end
  end
end
