userSchema = require "../schemas/user"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

waifu = (message, nick) ->
	args = message.split ' '
	if args.length == 1
		viewWaifu nick
	else
		switch args[1]
			when "-s", "--set"
				checkUser nick, message.replace(/\S+/, '').trim()
			else viewWaifu args[1]

viewWaifu = (nick) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.waifu
				doc.waifu
			else
				"No waifu found for #{nick}."
		else
			"No waifu found for #{nick}."

checkUser = (nick, waifu) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			doc.waifu = waifu
			changed = true
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then "Saved waifu."
		if !doc
			addUser nick, waifu

addUser = (nick, waifu) ->
	if validUrl.isUri waifu
		newUser = new User
			nick: nick
			waifu: waifu
	else
		"Invalid URL detected."
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			"Saved waifu."

module.exports =
	func: waifu
	help: "Save waifu: .waifu -s waifu"
