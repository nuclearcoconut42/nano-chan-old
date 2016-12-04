userSchema = require "../schemas/user"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

waifu = (bot, data) ->
  if data.args.length == 0
    viewWaifu data.to, data.from, bot
  else
    switch data.args[0]
      when "-s", "--set"
        if data.args.length > 1
          checkUser data.from, data.to, data.args[1..].join(" "), bot
        else
          checkUser data.from, data.to, "", bot
      else viewWaifu data.to, data.args[0], bot

viewWaifu = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.waifu
        bot.say channel, "(#{nick}) #{doc.waifu}"
      else
        bot.say channel, "No waifu found for #{nick}."
    else
      bot.say channel, "No waifu found for #{nick}."

checkUser = (nick, channel, waifu, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.waifu = waifu
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          bot.say channel, "#{nick}: Saved waifu."
    if !doc
      addUser nick, channel, waifu, bot

addUser = (nick, channel, waifu, bot) ->
  newUser = new User
    nick: nick
    waifu: waifu
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      bot.say channel, "#{nick}: Saved waifu."

module.exports =
  func: waifu
  help: "Save waifu: .waifu -s waifu"
