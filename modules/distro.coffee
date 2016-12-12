userSchema = require "../schemas/user"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

distro = (message, nick) ->
	args = message.split ' '
	if args.length == 1
		viewDistro nick
	else
		switch args[1]
			when "-s", "--set"
				checkUser nick, message.replace(/\S+/, '').trim()
			else viewDistro args[1]

viewDistro = (nick) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.distro
				doc.distro
			else
				"No distro found for #{nick}."
		else
			"No distro found for #{nick}."

checkUser = (nick, distro) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			doc.distro = distro
			changed = true
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then "Saved distro."
		if !doc
			addUser nick, distro

addUser = (nick, distro) ->
	newUser = new User
		nick: nick
		distro: distro
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			"Saved distro."

module.exports =
	func: distro
	help: "Save distro: .distro -s distro"
