# DIRCord

The only IRC Client you'll ever need, guaranteed!

## Features

- Create a discord server, each channel on discord corresponds to a channel on IRC!
- Creating a channel on discord joins the channel on IRC.
- Deleting a channel on discord leaves the channel on IRC!
- Speak in a channel name on discord, will send to that channel with same name on IRC and vice versa!

## Missing Features

Check the [issues](http://github.com/Chewsterchew/DIRCord/issues) to see what I'm planning next, or to suggest new things!
## Requirements

* [Ruby (>= 2.4)](https://www.ruby-lang.org/en/)
* [RVM](https://rvm.io/)
* [Git](https://git-scm.com/)

## Setup Guide

*You no longer need to make a discord server, as the bot automatically makes one, however, it is left here for manual setup.*
1) Create a server on Discord, copy the *server's ID*, you'll need it for later.

2) Copy your *user ID*, you'll need it for later.

3) Go to the [Discord Developer Portal](https://discordapp.com/developers/applications/) Make a new application, give it a name and an avatar if you want.  Copy the *Client ID*, you'll need it for later.  Then head to the **Bot** Section.  Create a bot, scroll down and select the **Administrator** Permission.  Make sure you unselect the slider that makes it a public bot, you don't want anyone but you to have this bot.  Hit the **Copy** button underneath where it says *Bot token*, you'll need this for later.

4) Invite the bot to the server, if you don't know how to do that, go [here](https://discordapi.com/permissions.html)  Click on the **Administrator** permission box, and scroll down.  Paste in your *Client ID* that you got from the Discord Developer Portal, and open the link at the bottom of the page.  **DO NOT CHECK ANY OTHER BOXES OTHER OR FILL IN ANYTHING ELSE OTHER THAN THE CLIENT ID.**

5) In the invite link, select your server that you made in Step 1, then invite the bot.

## Here is where the fun begins: *These steps should be universal, but might not work on all devices, these instructions were made for linux, specifically Ubuntu.*

6) Open up your CLI, and run `sudo apt update` to make sure that all of your packages are up to date.  

7) `git clone https://github.com/Chew/DIRCord.git` 

8) Enter the directory with `cd DIRCord`

9) Run `ruby requiregems.rb` if prompted to install the gems, respond with *y* for all.

10) `cp config.example.yaml config.yaml`This will copy the example config file into your config file.

11)  Using a text editor (such as Atom) or a command line editor (such as nano, emacs, or vim) open the *config.yaml* file and fill it out

```yaml
---
nickname: [irc nickname]
server: [irc server]
realname: [(your name) via DIRCord]
username: DIRCord
nickservpass: [nickserv username] [nickserv password]
ssl: 'true'
port: 6697
token: [discord bot's token from Step 3]
server_id: [id of discord server you made in Step 1]
user_id: [your discord user id from Step 2]
```
* nickserv username and password should be the same as your regular IRC account's username and password, so that way you get logged into the same stuff.
* ssl can be set to false, if it is, change the port to *6667* however it might be different depending on your server, contact your server's administrators for help.
**Replace all text in the brackets *[ ]* Including the brackets!**

12) `ruby main.rb` to start the bot.

13) Back in Discord, make new channels for the channels on IRC that you want to join.

## Your console on running

Will die, like ouch.

Discord reports about 3 things on start-up, and then any errors it finds in running.

IRC however, oh boy. On Startup, it will put a BUNCH OF STUFF in the console that probably makes no sense to you, I know it makes no sense to me.

Then, every 2 mins or so, it will "ping" the server, and get a "pong" back.

## Commands:
* `~help`: Shows a list of all the commands available or displays help for a specific command.
* `~users`: Get a list of users in the current channel.
* `~topic`: Update's discord channel's topic to match that of the connected IRC channel. Also displays channel modes.
* `~join`: Joins channel on IRC, and creates channel on Discord.
* `~setupwebhook`: Creates a webhook for this channel. All messages will be sent as webhooks.
* `~eval`: Evaluates Ruby expressions. Use with caution.
* `~highlights`: Manage your highlighted words. Use `list` to view alertable phrases you have set up, use `add` and `remove` to add or remove alertable phrases respectively.
