userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

github = (message, nick) ->
	args = message.split(' ')[1..]
	if args.length == 0
		viewGithub nick
	else
		switch args[0]
			when "-s", "--set"
				checkUser nick, message.replace(/\S+/, '').trim()
			else viewGithub args[0]

viewGithub = (nick) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.github
				doc.github
			else
				"No github found for #{nick}."
		else
			"No github found for #{nick}."

checkUser = (nick, github) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if validUrl.isUri(github)
				doc.github = github
				changed = true
			else
				"Invalid URL detected."
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then "Saved github."
		if !doc
			addUser nick, github

addUser = (nick, github) ->
	if validUrl.isUri github
		newUser = new User
			nick: nick
			github: github
	else
		"Invalid URL detected."
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			"Saved github."

module.exports =
	func: github
	help: "Save github: .github -s github"
