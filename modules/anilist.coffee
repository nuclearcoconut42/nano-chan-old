userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

anilist = (bot, data) ->
	if data.args.length == 0
		viewAnilist data.to, data.from, bot
	else
		switch data.args[0]
			when "-s", "--set"
				if data.args.length > 1
					checkUser data.from, data.to, data.args[1..].join(" "), bot
				else
					checkUser data.from, data.to, "", bot
			else viewAnilist data.to, data.args[0], bot

viewAnilist = (channel, nick, bot) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.anilist
				bot.say channel, "(#{nick}) #{doc.anilist}"
			else
				bot.say channel, "No anilist found for #{nick}."
		else
			bot.say channel, "No anilist found for #{nick}."

checkUser = (nick, channel, anilist, bot) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if validUrl.isUri(anilist)
				doc.anilist = anilist
				changed = true
			else
				bot.say channel, "Invalid URL detected."
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then bot.say channel, "#{nick}: Saved anilist."
		if !doc
			addUser nick, channel, anilist, bot

addUser = (nick, channel, anilist, bot) ->
	if validUrl.isUri(anilist)
		newUser = new User
			nick: nick
			anilist: anilist
	else
		bot.say channel, "Invalid URL detected."
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			bot.say channel, "#{nick}: Saved anilist."

module.exports =
	func: anilist
	help: "Save anilist: .anilist -s anilist"
