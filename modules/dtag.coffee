userSchema = require "../schemas/user"
dtopSchema = require "../schemas/dtop"
validUrl = require "valid-url"
mongoose = require "mongoose"
_ = require "lodash"

Dtop = mongoose.model 'Dtop', dtopSchema

dtop = (message, nick, channel, bot) ->
	args = message.split ' '
	if args.length == 1
		bot.say channel, viewDtops nick, []
	if args.length == 2
		regex = /(#\S+)|([a-zA-Z]+)/
		tags = []
		while match = regex.exec message
			if match[1] then tags.push match[1]
			if match[2] then user = match[2]
		bot.say channel, "#{nick}: #{viewDtops user, []}"
	else
		switch args[1]
			when '-a', '--add'
				regex = /(\S+) ?((#\S+ )+#\S+)?/g
				dtops = []
				while match = regex.exec message
					dtops.push [match[1], match[2].split ' ']
				bot.say channel, "#{nick}: #{addDtops dtops, nick}"
			when '-d', '--delete', '--remove'
				regex = /(\d+)|((\d+)(-|\||(..))(\d+))|(#\S+)/g
				selection = []
				tags = []
				while match = regex.exec message
					if match[1] then selection.push match[1]
					if match[2] && match[3] && match[6]
						selection.concat [match[3]..match[6]]
					if match[7] then tags.push match[7]
				bot.say channel, "#{nick}: #{deleteDtops selection, tags, nick}"
			when '-r', '--replace'
				ids = args[2..].filter (element, index) -> index % 2 == 0
				urls = args[2..].filter (element, index) -> index % 2 == 1
				bot.say channel "#{nick}: #{replaceDtops ids, urls, nick}"
			else
				regex = /(#\S+)|([a-zA-Z]+)/
				tags = []
				while match = regex.exec message
					if match[1] then tags.push match[1]
					if match[2] then user = match[2]
				bot.say channel, "#{nick}: #{viewDtops user, tags}"

viewDtops = (nick, tags) ->
	if nick && tags
		User.find
			nick: nick
      dtops:
        $elemMatch:
			    tags:
				    $all: tags
			(err, doc) ->
				if doc
					ret = "(#{nick}) "
					doc.forEach (element, index) ->
						ret += "[#{index}] #{element.} "
					ret.trim()
				else
					"No desktops found"
	else if tags
		Dtop.find {tags: $all: tags} .limit(10)
			(err, doc) ->
				if doc
					ret = ""
					doc.forEach (element, index) ->
						ret += "#{element.dtop} "
						ret.trim()
				else
					"No desktops found"

addDtops = (dtops, nick) ->
	for dtop in dtops
    User.findOne {nick: nick} (err, doc) ->
      doc.dtops.push
        dtop: dtops[0]
        tags: dtops[1]
      doc.save
	"Saved."

deleteDtops ids, tags, nick
  Dtop.remove
    
