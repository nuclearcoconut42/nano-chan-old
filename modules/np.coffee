userSchema = require "../schemas/user"
mongoose = require "mongoose"
lastfmapi = require "lastfm"
config = require "../config.coffee"

User = mongoose.model('User', userSchema)

np = (bot, data) ->
  if data.args.length == 0
    nowplaying data.to, data.from, bot
  else
    switch data.args[0]
      when "-s", "--set"
        if data.args.length > 1
          checkUser data.from, data.to, data.args[1], bot
        else
          checkUser data.from, data.to, "", bot
      else nowplaying data.to, data.args[0], bot

nowplaying = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
		if doc?
			if doc.lastfm?
				api = new lastfmapi(
					api_key: config.lastfmApiKey
					secret: config.lastfmSecret
					useragent: doc.lastfm
				)
				request = api.request "user.getRecentTracks", api
				request.on "success", (json) -> bot.say channel, "#{nick}: #{JSON.stringify json}"
			else
        bot.say channel, "No last.fm account found for #{nick}."
		else
      bot.say channel, "No last.fm account found for #{nick}."

checkUser = (nick, channel, lastfm, bot) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
      doc.lastfm = lastfm
      doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
          bot.say channel, "#{nick}: Saved last.fm account."
		if !doc
      addUser nick, channel, lastfm, bot

addUser = (nick, channel, lastfm, bot) ->
  newUser = new User
    nick: nick
    lastfm: lastfm
  newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
      bot.say channel, "#{nick}: Saved last.fm account."

module.exports =
  func: np
  help: "Save last.fm account: .np -s [username]; Find now playing songs .np [nick]"
