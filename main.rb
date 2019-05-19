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
  begin
    dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == "Direct Messages" }.id
  rescue NoMethodError
    dm_category = 0
  end

  if event.channel.parent_id == dm_category
    Irc.User(event.channel.name).send(event.message.content.to_s)
  else
    Irc.Channel("\##{event.channel.name}").send(event.message.content.to_s)
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
  begin
    dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == "Direct Messages" }.id
  rescue NoMethodError
    dm_category = 0
  end

  Irc.Channel("\##{event.channel.name}").join if event.channel.text? && event.channel.parent_id != dm_category
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

    begin
      dm_category = Discord.server(CONFIG['server_id']).categories.find { |chane| chane.name == "Direct Messages" }.id
    rescue NoMethodError
      dm_category = 0
    end

    # Bot Settings, Taken from pre-config
    c.nick = botnick
    c.server = botserver

    chans = []
    Discord.server(CONFIG['server_id']).text_channels.each { |bob| chans.push("\##{bob.name}") unless bob.parent_id == dm_category }

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
