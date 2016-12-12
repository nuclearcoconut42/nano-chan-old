userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

anilist = (message, nick) ->
	args = message.split ' '
	if args.length == 1
		viewAnilist nick
	else
		switch args[1]
			when "-s", "--set"
				checkUser nick, message.replace(/\S+/, '').trim()
			else viewAnilist args[1]

viewAnilist = (nick) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.anilist
				doc.anilist
			else
				"No anilist found for #{nick}."
		else
			"No anilist found for #{nick}."

checkUser = (nick, anilist) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if validUrl.isUri(anilist)
				doc.anilist = anilist
				changed = true
			else
				"Invalid URL detected."
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then "Saved anilist."
		if !doc
			addUser nick, anilist

addUser = (nick, anilist) ->
	if validUrl.isUri anilist
		newUser = new User
			nick: nick
			anilist: anilist
	else
		"Invalid URL detected."
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			"Saved anilist."

module.exports =
	func: anilist
	help: "Save anilist: .anilist -s anilist"
