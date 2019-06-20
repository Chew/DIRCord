# DIRCord

The only IRC Client you'll ever need, guaranteed!

## Features

- Create a discord server, each channel on discord corresponds to a channel on IRC!
- Creating a channel on discord joins the channel on IRC.
- Deleting a channel on discord leaves the channel on IRC!
- Speak in a channel name on discord, will send to that channel with same name on IRC and vice versa!

## Missing Features

Check the [issues](http://github.com/Chew/DIRCord/issues) to see what I'm planning next, or to suggest new things!

## Requirements

* Ruby (>= 2.4)
* Git

## Setup Guide

### Setting up the Environment

Before we get to the actual setup, we need to set up our program environment.

#### Ubuntu Setup

1) Open up your CLI, and run `sudo apt update` to make sure that all of your packages are up to date.  

2) `git clone https://github.com/Chew/DIRCord.git` 

3) Enter the directory with `cd DIRCord`

Now that this is set up, off to getting the program ready. We have 2 paths for this, you can take the lazy (yet most efficient) way by using the convient setup file, otherwise you can do it all manually.

### Automatic Setup

0) Make note of your Discord user ID, you'll need it for later.

2) Run `ruby setup.rb`. Make sure to follow all the steps for Discord AND IRC.

3) Run `ruby main.rb` to start.

4) Sit back and enjoy DIRCord!

### Manual Setup

1) Create a server on Discord, make note of the *server's ID*, you'll need it for later.

2) Make note of your *user ID* from Discord, you'll need it for later.

3) Go to the [Discord Developer Portal](https://discordapp.com/developers/applications/) and make a new application, give it a name and an avatar if you want. Then, head to the **Bot** section, then click create a bot. Make note of the **Copy** button underneath where it says *bot token*, you'll need this for later.

4) Invite the bot to the server, if you don't know how to do that, go to the **OAuth2** tab, scroll down and click **Bot**, scroll down, and click on the **Administrator** permission box. Copy the new URL between the 2 boxes and open this URL. Add it to your server you made in step 1.

5) Run `ruby requiregems.rb` if prompted to install the gems, respond with *y* for all.

6) Run `cp config.example.yaml config.yaml`, this will copy the example config file into your config file.

7) Using a text editor (such as Atom) or a command line editor (such as nano, emacs, or vim) open the *config.yaml* file and fill it out.

8) Run `ruby main.rb` to start.

9) Enjoy DIRCord!

## Your console on running

Will die, like ouch.

Discord reports about 3 things on start-up, and then any errors it finds in running.

IRC however, oh boy. On Startup, it will put a BUNCH OF STUFF in the console that probably makes no sense to you, I know it makes no sense to me.

Then, every 2 mins or so, it will "ping" the server, and get a "pong" back.

## Commands

* `~help`: Shows a list of all the commands available or displays help for a specific command.
* `~users`: Get a list of users in the current channel.
* `~topic`: Update's discord channel's topic to match that of the connected IRC channel. Also displays channel modes.
* `~join`: Joins channel on IRC, and creates channel on Discord.
* `~setupwebhook`: Creates a webhook for this channel. All messages will be sent as webhooks.
* `~eval`: Evaluates Ruby expressions. Use with caution.
* `~highlights`: Manage your highlighted words. Use `list` to view alertable phrases you have set up, use `add` and `remove` to add or remove alertable phrases respectively.
