irc = require "irc"
config = require "./config"
meta = require "node-metainspector"
mongoose = require "mongoose"
requireDir = require "require-dir"

modules = requireDir './modules'
alias = require './alias'

mongoose.connect 'mongodb://localhost:27017/nano-chan'
db = mongoose.connection
db.on 'error', console.error.bind console, 'connection error:'
db.once 'open', ->
	console.log "Connected!"
	bot = new irc.Client config.network, config.nick,
		channels: config.channels

	bot.addListener 'registered', -> bot.say 'NickServ', 'identify ' + config.password

	bot.addListener 'message', (from, to, message) ->
		message = message.trim()
		if message.match /^\.bots/
			bot.notice to, "Reporting in! [node.js] (https://github.com/nuclearcoconut42/nano-chan)"
		else if message.match /^\.help/
			bot.say from, "List of commands: #{JSON.stringify Object.keys(modules)}"
			bot.say from, "Find help on individual commands with ?[command] (without brackets)"
		else if message.match /^\./
			split = message.split ' '
			command = split[0].substring 1
			args = split[1..]
			if modules[command] then modules[command].func bot,
				from: from
				to: to
				args: args
			else if alias[command] then alias[command].func bot,
				from: from
				to: to
				args: args
			else bot.say to, "#{from}: Unknown command"
		else if message.match /^\?./
			split = message.split ' '
			command = split[0].substring 1
			if modules[command] then bot.say to, "#{from}: #{modules[command].help}"
			else if alias[command] then bot.say to, "#{from}: #{alias[command].help}"
			else bot.say to, "#{from}: Unknown command."
		# if message.match /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b(-a-zA-Z0-9@:%_\+.~#?&=]*)/
		# 	client = new meta(

	bot.addListener 'pm', (from,  message) ->
		message = message.trim()
		if message.match /^\.help/
			bot.notice from, "List of commands: #{JSON.stringify Object.keys(modules)}"
		else if message.match /^\./
			split = message.split ' '
			command = split[0].substring 1
			args = split[1..]
			if modules[command] then modules[command].func bot,
				from: from
				to: from
				args: args
			else if alias[command] then alias[command].func bot,
				from: from
				to: from
				args: args
			else bot.say from, "#{from}: Unknown command"
		else if message.match /^\?./
			split = message.split ' '
			command = split[0].substring 1
			if modules[command] then bot.say from, "#{from}: #{modules[command].help}"
			else if alias[command] then bot.say to, "#{from}: #{alias[command].help}"
			else bot.say from, "#{from}: Unknown command."
		# if message.match /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b(-a-zA-Z0-9@:%_\+.~#?&=]*)/
		# 	client = new meta(
