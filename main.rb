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
    return if Time.now.to_i - STARTTIME.to_i == 10
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

Discord.command(:users) do |event|
  channel = Irc.Channel("\##{event.channel.name}")
  users = channel.users.keys.join(' ').split(' ')
  modes = []
  channel.users.each { |e| modes[modes.length] = e[1] }

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
    owners[owners.length] = users[i] if mod == 'q'
    admins[admins.length] = users[i] if mod == 'a'
    ops[ops.length] = users[i] if mod == 'o'
    halfops[halfops.length] = users[i] if mod == 'h'
    voiced[voiced.length] = users[i] if mod == 'v'
  end
  output = []
  output += ['**Owners**', owners.join(', '), ''] unless owners.length.zero?
  output += ['**Admins**', admins.join(', '), ''] unless admins.length.zero?
  output += ['**Ops**', ops.join(', '), ''] unless ops.length.zero?
  output += ['**Halfops**', halfops.join(', '), ''] unless halfops.length.zero?
  output += ['**Voiced**', voiced.join(', '), ''] unless voiced.length.zero?
  output += ['**Member**', member.join(', '), ''] unless member.length.zero?
  event.respond output.join("\n")
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

Discord.message_edit do |_event|
  Discord.user(CONFIG['user_id']).pm("Hey, you just edited a message, just wanted to let you know that IRC users don't see the edited message, only the original. Thanks!")
end

Discord.message_delete do |_event|
  Discord.user(CONFIG['user_id']).pm('Hey, you just deleted a message, just wanted to let you know that IRC users still see the deleted message. Thanks!')
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
