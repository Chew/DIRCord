module Highlights
  extend Discordrb::Commands::CommandContainer

  command(:highlights, min_args: 1, max_args: 2, description: 'Manage your highlighted words. Use *list* to view alertable phrases you have set up, use *add* and *remove* to add or remove alertable phrases respectively.') do |event, action, word|
    if CONFIG['highlights'].nil?
      CONFIG['highlights'] = ''
      File.open(CONFIG_FILE, 'w') { |f| f.write CONFIG.to_yaml }
    end

    highlights = CONFIG['highlights'].split(',')

    case action
    when 'list'
      if highlights.empty?
        event.respond 'Currently no highlighted words!'
      else
        event.respond "Highlighted words: ```#{highlights.join("\n")}```"
      end
    when 'add'
      event.respond "Added highlighted word #{word}"
      highlights.push(word)
    when 'remove'
      event.respond "Removed highlighted word #{word}"
      highlights.delete(word)
    else
      event.respond 'Invalid action :( Try `list`, `add`, `remove`'
    end
    CONFIG['highlights'] = highlights.join(',')
    File.open(CONFIG_FILE, 'w') { |f| f.write CONFIG.to_yaml }
    nil
  end
end
