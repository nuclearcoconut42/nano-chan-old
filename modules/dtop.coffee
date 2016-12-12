userSchema = require "../schemas/user"
validUrl = require "valid-url"
mongoose = require "mongoose"
_ = require "lodash"
assert = require "assert"

mongoose.Promise = require('q').Promise

User = mongoose.model 'User', userSchema, 'users'

dtop = (message, nick, cb) ->
	args = message.split ' '
	if args.length == 1
		return viewDtops nick, [], cb
	else
		switch args[1]
			when '-a', '--add'
				console.log 'memes'
				regex = /\.dtop --?[a-z]+ (\S+) ?((#\S+ ?)*)/g
				dtops = []
				while match = regex.exec message
					console.log match
					if match[3]
						dtops.push [match[1], match[3].trim().split ' ']
					else
						dtops.push [match[1], []]
				addDtops dtops, nick, cb
			when '-d', '--delete', '--remove'
				regex = /(\d+)|((\d+)(-|\||(..))(\d+))|(#\S+)/g
				selection = []
				tags = []
				while match = regex.exec message
					if match[1] then selection.push match[1]
					if match[2] && match[3] && match[6]
						selection.concat [match[3]..match[6]]
					if match[7] then tags.push match[7]
				deleteDtops selection, tags, nick, cb
			when '-r', '--replace'
				regex = /(\d+) (\S+) ?((#\S+ ?)+)/g
				selection = []
				dtops = []
				while match = regex.exec message
					ids.push match[1]
					dtops.push [match[2], match[3].trim().split ' ']
				replaceDtops selection, dtops, nick, cb
			else
				if args[1][0] == '#'
					regex = /(#\S+)/g
					tags = []
					while match = regex.exec message
						tags.push match[1]
					viewDtops nick, tags, cb
				regex = /((#\S+ ?)+)|([a-zA-Z]+)/
				tags = []
				while match = regex.exec message
					if match[2] then tags.push match[1]
					if match[3] then user = match[2]
				viewDtops user, tags, cb

viewDtops = (nick, tags, cb) ->
	console.log nick, tags
	ret = ""
	if nick && tags.length > 0
		query = User.findOne
			nick: nick
			dtops:
				tags:
					$all: tags
		assert.ok(query.exec() instanceof require('q').makePromise)
		query.exec().then (doc) ->
			if doc
				ret = "(#{nick}) "
				doc.dtops.forEach (element, index) ->
					ret += "[#{index}] #{element.dtop} #{JSON.stringify element.tags} "
			else
				cb "No desktops found."
			cb ret
	else if nick
		query = User.findOne
			nick: nick
		assert.ok(query.exec() instanceof require('q').makePromise)
		query.exec().then (doc) ->
			if doc
				ret = "(#{nick}) "
				doc.dtops.forEach (element, index) ->
					ret += "[#{index+1}] #{element.dtop} #{JSON.stringify element.tags} "
			cb ret

addDtops = (dtops, nick, cb) ->
	for dtop in dtops
		if validUrl.isUri(dtop[0])
			User.findOne {nick: nick}, (err, doc) ->
				if doc
					console.log doc
					doc.dtops.push
						dtop: dtop[0]
						tags: dtop[1]
					doc.save (err) ->
						if err then console.error err
				else
					User.create
						dtops: [
							dtop: dtop[0]
							tags: dtop[1]
						]
						nick: nick
						(err, doc) ->
							console.log "doc: #{doc}"
							console.log "dtops: #{doc.dtops}"
							if err then console.error err
	cb "Saved."

deleteDtops = (ids, tags, nick, cb) ->
	User.findOne
		nick: nick
		(err, doc) ->
			if doc
				doc.dtops.forEach (element, index) ->
					if index of ids || _.intersection element.tags, tags .length == tags.length
						element.remove()
				doc.save (err) -> console.error err
	cb "Removed."

replaceDtops = (ids, dtops, nick, cb) ->
	User.findOne
		nick: nick
		(err, doc) ->
			if doc
				ids.forEach (element, index) ->
					dtops[element] =
						dtop: dtops[index][0]
						tags: dtops[index][1]
					doc.save (err) -> console.error err
	cb "Replaced."

module.exports =
	func: dtop
	help: "Set your dtops: .dtop -a dtop [tags] dtop [tags] etc. (see https://github.com/nucclearcoconut42/nano-chan for more info."
