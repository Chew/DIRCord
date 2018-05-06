# DIRCord

# Require Gems needed to run the program
require './requiregems.rb'

# Load config from file
begin
  CONFIG = YAML.load_file('config.yaml')
rescue StandardError
  puts 'Config file not found, this is fatal.'
  exit
end

# Set up uptime.
STARTTIME = Time.now

# Pre-Config
botnick = if CONFIG['nickname'] == '' || CONFIG['nickname'].nil?
            puts 'The bot doesn\'t have a nickname! Please set one'
            exit
          else
            CONFIG['nickname'].to_s
          end

botserver = if CONFIG['server'] == '' || CONFIG['server'].nil?
              puts 'You did not configure a server for the bot to connect to. Please set one!'
              exit
            else
              CONFIG['server'].to_s
            end

botport = if CONFIG['port'].nil?
            '6667'
          else
            CONFIG['port']
          end

botuser = if CONFIG['username'].nil? || CONFIG['username'] == ''
            CONFIG['nickname']
          else
            CONFIG['username']
          end

botrealname = if CONFIG['realname'].nil? || CONFIG['realname'] == ''
                'Proud DIRCord User! http://github.com/Chewsterchew/DIRCord'
              else
                (CONFIG['realname']).to_s
              end

botssl = if CONFIG['ssl'].nil? || CONFIG['ssl'] == '' || CONFIG['ssl'] == 'false' || CONFIG['ssl'] == false
           nil
         else
           'true'
         end

botserverpass = if CONFIG['serverpass'].nil? || CONFIG['serverpass'] == ''
                  nil
                else
                  CONFIG['serverpass']
                end

Discord = Discordrb::Commands::CommandBot.new token: CONFIG['token'], client_id: CONFIG['client_id'], prefix: '~'

class About
  include Cinch::Plugin

  listen_to :channel, method: :send
  listen_to :connect, method: :identify
  listen_to :leaving, method: :leave
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
    channel = m.channel.to_s[1..m.channel.to_s.length]
    name = m.user.name
    message = m.message
    chan = Discord.server(CONFIG['server_id']).text_channels.find { |chane| chane.name == channel.downcase }.id

    message.gsub!(CONFIG['nickname'], "<@#{CONFIG['user_id']}>")
    message.gsub!(/([0-9]\d{0,2})/, '')

    Discord.channel(chan).send("**<#{name}>** #{message}")
  end
end

Discord.message(start_with: not!('~'), from: CONFIG['user_id']) do |event|
  Irc.Channel("\##{event.channel.name}").send(event.message.content.to_s)
end

Discord.command(:topic) do |event|
  modes = []
  m = Irc.Channel("\##{event.channel.name}")
  m.modes.each do |e, _f|
    modes[modes.length] = e
  end
  event.channel.topic = "[+#{modes.join('')}] #{m.topic.gsub!(/([0-9]\d{0,2})/, '')}"
  event.respond 'Set the channel topic!'
end

puts 'Initial Startup complete, loading all plugins...'

Discord.ready do |_meme|
  puts 'ready!'
end

Discord.channel_create do |event|
  Irc.Channel("\##{event.channel.name}").join if event.channel.text?
end

Discord.channel_delete do |event|
  Irc.Channel("\##{event.name}").part if event.type.zero?
end

puts 'Bot is ready!'
Discord.run :async

# Configure the Bot
Irc = Cinch::Bot.new do
  configure do |c|
    # Bot Settings, Taken from pre-config
    c.nick = botnick
    c.server = botserver

    chans = []
    Discord.server(CONFIG['server_id']).text_channels.each { |bob| chans[chans.length] = "\##{bob.name}" }

    c.channels = [chans.join(',')]
    c.port = botport
    c.user = botuser
    c.realname = botrealname
    c.messages_per_second = 2
    c.ssl.use = botssl
    c.password = botserverpass

    c.plugins.plugins = [About]
  end
end
Irc.start
