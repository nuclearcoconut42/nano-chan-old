userSchema = require "../schemas/user"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

distro = (bot, data) ->
  if data.args.length == 0
    viewDistro data.to, data.from, bot
  else
    switch data.args[0]
      when "-s", "--set"
        if data.args.length > 1
          checkUser data.from, data.to, data.args[1..].join(" "), bot
        else
          checkUser data.from, data.to, "", bot
      else viewDistro data.to, data.args[0], bot

viewDistro = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.distro
        bot.say channel, "(#{nick}) #{doc.distro}"
      else
        bot.say channel, "No distro found for #{nick}."
    else
      bot.say channel, "No distro found for #{nick}."

checkUser = (nick, channel, distro, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.distro = distro
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          bot.say channel, "#{nick}: Saved distro."
    if !doc
      addUser nick, channel, distro, bot

addUser = (nick, channel, distro, bot) ->
  newUser = new User
    nick: nick
    distro: distro
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      bot.say channel, "#{nick}: Saved distro."

module.exports =
  func: distro
  help: "Save distro: .distro -s distro"
