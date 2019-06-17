class Setup
  def initialize
    begin
      require 'yaml'
    rescue LoadError
      puts 'YAML not found! Is your ruby ok?'
      exit
    end
    unless File.exist?('config.yaml')
      puts 'No config file! Creating one now..'
      File.new('config.yaml', 'w+')
      exconfig = YAML.load_file('config.example.yaml')
      File.open('config.yaml', 'w') { |f| f.write exconfig.to_yaml }
    end
    @config = YAML.load_file('config.yaml')
    exit if @config == false
  end

  def welcome(skipwelcome = true)
    unless skipwelcome
      puts 'Welcome to DIRCord setup'
      puts 'This really simple GUI will guide you in setting up the program by yourself!'
      puts 'Press enter to get started'
      gets
    end
    puts 'What would you like to do? (type number then press enter)'
    puts '[1] - Setup Discord'
    puts '[2] - Set up IRC'
    puts '[3] - Exit!'
    input = gets.chomp

    discord if input == '1'
    irc if input == '2'
    exit
  end

  def discord
    puts 'Alright! Discord time.'

    puts 'What would you like to do?'
    puts '[1] - Create/Setup Bot Application'
    puts '[2] - Create/Setup Discord Server'
    puts '[3] - Setup Discord Config'
    puts '[4] - Main Menu'
    input = gets.chomp

    configure('botapp') if input == '1'
    configure('discordserver') if input == '2'
    configure('discordconf') if input == '3'
    welcome
  end

  def irc
    puts 'Alright! IRC time.'

    puts 'What would you like to do?'
    puts '[1] - Setup Connection Information'
    puts '[2] - Setup IRC User Agent'
    puts '[3] - Main Menu'
    input = gets.chomp

    configure('irconnect') if input == '1'
    configure('ircuser') if input == '2'
    welcome
  end

  def configure(section)
    if section == 'botapp'
      puts "This will help you setup your bot application. You must create a new bot for each instance."
      puts "To advance to the next step, press enter."
      gets
      puts "Go to your applications page on the Discord found at https://discordapp.com/developers/applications"
      gets
      puts "Click New Application and name it something you'll remember. Maybe the IRC network name? DIRCord?"
      gets
      puts "Click the 'Bot' tab on the left, then click 'Add Bot', then 'Yes, do it!'"
      gets
      puts "Now, click Copy to copy the token and paste it here."
      @config['token'] = gets.chomp
      puts "All done :)"
      save
      discord
    end

    if section == 'discordserver'
      puts "This step will make the bot create a server for you, and it will give you an awesome invite link. Then, just join!"
      puts "To advance to the next step, press enter."
      gets
      puts "Alright, first we check to see if you have discordrb installed!"
      begin
        require 'discordrb'
        require 'discordrb/webhooks'
      rescue LoadError
        puts "You're missing the gem `discordrb`. Would you like to install this now? (y/n)"
        input = gets.chomp
        if input == 'y'
          `gem install discordrb`
          puts 'Gem installed! Continuing..'
        else
          puts 'To continue, install the discordrb gem'
          exit
        end
      end
      puts "Logging into Discord..."
      puts "Hey, btw, whatcha want the name of the Discord server to be?"
      name = gets.chomp
      begin
        bot = Discordrb::Commands::CommandBot.new token: @config['token'], prefix: '~'
        bot.run(:async)
        begin
          server = bot.create_server(name)
        rescue StandardError => e
          puts "An error occured creating the server! Make sure you put in a token!"
          puts "Error: #{e}"
          bot.stop
          discord
        end
        invite = server.default_channel.make_invite
        server.create_channel("Direct Messages", 4, reason: "Direct Message Channel")
        server.everyone_role.packed = 8
        server.voice_channels.each { |ch| ch.delete }
        server.categories.each { |ch| ch.delete if ch.name == "Voice Channels" }
        bot.stop
        puts "Server created! Here's the invite: #{invite.url}"
        @config['server_id'] = server.id.to_i
        save
      rescue StandardError => e
        puts "An error occured creating the server! Make sure you put in a token!"
        puts "Error: #{e}"
      end
      discord
    end

    if section == 'discordconf'
      puts "Discord config is actually super easy, barely an inconvenience."
      puts 'Set your discord user id - REQUIRED'
      @config['user_id'] = gets.chomp.to_i

      puts 'It turns out you\'re done configuring Discord settings!'
      save
      discord
    end

    if section == 'irconnect'
      puts 'Enter the server address (hostname, IP, whatever, NO PORT yet) - REQUIRED'
      @config['server'] = gets.chomp

      puts 'Enter the server port, if you don\'t know, use 6667 - REQUIRED'
      @config['port'] = gets.chomp

      puts 'Connect using SSL? (true/false), if you don\'t know, press enter.'
      input = gets.chomp
      @config['ssl'] = true?(input)

      puts 'Done configuring server connection information!'
      save
      irc
    end

    if section == 'ircuser'
      puts 'Pick a nickname for the bot - REQUIRED'
      @config['nickname'] = gets.chomp

      puts "What should be the bot's realname? This is shown in a whois. - Optional"
      @config['realname'] = gets.chomp

      puts 'What should be the bot\'s USERNAME? (this is what\'s shown before the @ in a hostname. e.g. chew!THIS@blah) - Optional'
      @config['username'] = gets.chomp

      puts 'NickServ Password - Optional'
      @config['nickservpass'] = gets.chomp

      puts 'It turns out you\'re done configuring IRC uSer agent settings!'
      save
      irc
    end
  end

  def save
    File.open('config.yaml', 'w') { |f| f.write @config.to_yaml }
  rescue StandardError => e
    puts 'uh oh, there was an error saving. Report the following error to Chew on github'
    puts e
  end

  def true?(obj)
    obj.to_s == 'true'
  end
end

jerry = Setup.new
jerry.welcome(false)
