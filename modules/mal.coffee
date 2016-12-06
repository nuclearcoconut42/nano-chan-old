userSchema = require "../schemas/user"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

mal = (bot, data) ->
  if data.args.length == 0
    viewMAL data.to, data.from, bot
  else
    switch data.args[0]
      when "-s", "--set"
        if data.args.length > 1
          checkUser data.from, data.to, data.args[1..].join(" "), bot
        else
          checkUser data.from, data.to, "", bot
      else viewMAL data.to, data.args[0], bot

viewMAL = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.mal
        bot.say channel, "(#{nick}) #{doc.mal}"
      else
        bot.say channel, "No MAL account found for #{nick}."
    else
      bot.say channel, "No MAL account found for #{nick}."

checkUser = (nick, channel, mal, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.mal = mal
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          bot.say channel, "#{nick}: Saved MAL account."
    if !doc
      addUser nick, channel, mal, bot

addUser = (nick, channel, mal, bot) ->
  newUser = new User
    nick: nick
    mal: mal
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      bot.say channel, "#{nick}: Saved MAL account."

module.exports =
  func: mal
  help: "Save MAL account: .mal -s mal"
