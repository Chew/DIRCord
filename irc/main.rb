class About
  include Cinch::Plugin

  listen_to :channel, method: :send
  listen_to :connect, method: :identify
  listen_to :leaving, method: :leave
  listen_to :catchall, method: :net
  # listen_to :join, method: :join

  def identify(_m)
    User('NickServ').send("identify #{CONFIG['nickservpass']}") unless CONFIG['nickservpass'].nil? || CONFIG['nickservpass'] == ''
    Irc.oper(CONFIG['operpass'], CONFIG['operusername']) unless CONFIG['operpass'].nil? || CONFIG['operpass'] == '' || CONFIG['operusername'].nil? || CONFIG['operusername'] == ''
  end

  # def join(m, user)
  #  if m.channel?
  #    channel = m.channel.to_s[1..m.channel.to_s.length]
  #    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase }.id
  #    message = format('*→ %s joined (%s)*', user, user.host)
  #    Discord.channel(chan).send(message)
  #  end
  # end

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

  def net(m); end
end
