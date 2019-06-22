module Version
  extend Discordrb::Commands::CommandContainer

  command(:update) do |event|
    m = event.respond 'Updating...'
    changes = `git pull`
    m.edit('', Discordrb::Webhooks::Embed.new(
                 title: '**Updated Successfully**',

                 description: changes,
                 color: 0x7ED321
               ))
  end

  command(:version) do |event|
    `git fetch`
    response = `git rev-list origin/master | wc -l`.to_i
    commits = `git rev-list master | wc -l`.to_i
    if commits.zero?
      event.respond 'Git machine broke! Call the department!'
      break
    end
    event.channel.send_embed do |e|
      e.title = "You are running DIRCord commit \##{commits}"
      if response == commits
        e.description = 'You are running the latest commit.'
        e.color = '00FF00'
      elsif response < commits
        e.description = "You are running an un-pushed commit! Are you a developer? (Most Recent: #{response})\n**Here are up to 5 most recent commits.**\n#{`git log origin/master..master --pretty=format:\"[%h](http://github.com/Chew/DIRCord/commit/%H) - %s\" -5`}"
        e.color = 'FFFF00'
      else
        e.description = "You are #{response - commits} commit(s) behind! Run `hq, update` to update.\n**Here are up to 5 most recent commits.**\n#{`git log master..origin/master --pretty=format:\"[%h](http://github.com/Chew/DIRCord/commit/%H) - %s\" -5`}"
        e.color = 'FF0000'
      end
    end
  end
end
