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

# Require each irc plugin
Dir["#{File.dirname(__FILE__)}/irc/*.rb"].each { |file| require file }

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
  event.channel.send_embed do |embed|
    embed.title = "IRC Members in #{event.channel.name}"
    embed.colour = 0xe7cf31

    embed.add_field(name: '~Owners', value: owners.join(', '), inline: true) unless owners.length.zero?
    embed.add_field(name: '&Admins', value: admins.join(', '), inline: true) unless admins.length.zero?
    embed.add_field(name: '@Ops', value: ops.join(', '), inline: true) unless ops.length.zero?
    embed.add_field(name: '%Halfops', value: halfops.join(', '), inline: true) unless halfops.length.zero?
    embed.add_field(name: '+Voiced', value: voiced.join(', '), inline: true) unless voiced.length.zero?
    embed.add_field(name: 'Member', value: member.join(', '), inline: true) unless member.length.zero?
  end
end

Dir["#{File.dirname(__FILE__)}/discord/*.rb"].each { |file| require file }

Dir["#{File.dirname(__FILE__)}/discord/*.rb"].each do |wow|
  bob = File.readlines(wow) { |line| line.split.map(&:to_s).join }
  command = bob[0][7..bob[0].length]
  command.delete!("\n")
  command = Object.const_get(command)
  Discord.include! command
  puts "Disord plugin #{command} successfully loaded!"
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
