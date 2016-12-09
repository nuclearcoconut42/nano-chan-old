userSchema = require "../schemas/user"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

wm = (bot, data) ->
  if data.args.length == 0
    viewWm data.to, data.from, bot
  else
    switch data.args[0]
      when "-s", "--set"
        if data.args.length > 1
          checkUser data.from, data.to, data.args[1..].join(" "), bot
        else
          checkUser data.from, data.to, "", bot
      else viewWm data.to, data.args[0], bot

viewWm = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.wm
        bot.say channel, "(#{nick}) #{doc.wm}"
      else
        bot.say channel, "No window manager found for #{nick}."
    else
      bot.say channel, "No window manager found for #{nick}."

checkUser = (nick, channel, wm, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.wm = wm
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          bot.say channel, "#{nick}: Saved window manager."
    if !doc
      addUser nick, channel, wm, bot

addUser = (nick, channel, wm, bot) ->
  newUser = new User
    nick: nick
    wm: "wm"
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      bot.say channel, "#{nick}: Saved window manager."

module.exports =
  func: wm
  help: "Save window manager: .wm -s wm"
