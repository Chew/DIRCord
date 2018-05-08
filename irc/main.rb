class About
  include Cinch::Plugin

  listen_to :channel, method: :send
  listen_to :connect, method: :identify
  listen_to :leaving, method: :leave
  listen_to :catchall, method: :net

  def identify(_m)
    User('NickServ').send("identify #{CONFIG['nickservpass']}") unless CONFIG['nickservpass'].nil? || CONFIG['nickservpass'] == ''
    Irc.oper(CONFIG['operpass'], CONFIG['operusername']) unless CONFIG['operpass'].nil? || CONFIG['operpass'] == '' || CONFIG['operusername'].nil? || CONFIG['operusername'] == ''
  end

  def join(nick, user, host, channel)
    channel = channel[1..channel.length]
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase }.id
    message = format('*→ %s joined (%s@%s)*', nick, user, host)
    Discord.channel(chan).send(message)
  end

  def leave(m, user)
    if m.channel?
      channel = m.channel.to_s[1..m.channel.to_s.length]
      chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase }.id
      message = format('*⇐ %s left (%s)*', user, user.host)
      Discord.channel(chan).send(message)
      # else
      # message = format(' %s (%s) quit.', user, user.host)
    end
  end

  def send(m)
    return if Time.now.to_i - STARTTIME.to_i == 10
    channel = m.channel.to_s[1..m.channel.to_s.length]
    name = m.user.name
    message = m.message
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase }.id

    message.gsub!(CONFIG['nickname'], "<@#{CONFIG['user_id']}>")
    message.gsub!(/([0-9]\d{0,2})/, '')

    Discord.channel(chan).send("**<#{name}>** #{message}")
  end

  def net(m)
    content = m.raw
    data = content.split(' ')
    userhost = data[0].delete(':')
    command = data[1]
    channel = data[2].delete(':')
    uh = userhost.split(/!|@/)
    nick = uh[0]
    user = uh[1]
    host = uh[2]
    join(nick, user, host, channel) if command == 'JOIN'
  end
end
