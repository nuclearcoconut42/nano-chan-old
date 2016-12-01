userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

domain = (bot, data) ->
  if data.args.length == 0
    viewDomain data.to, data.from, bot
  else
    switch data.args[0]
      when "-s", "--set"
        if data.args.length > 1
          checkUser data.from, data.to, data.args[1..].join(" "), bot
        else
          checkUser data.from, data.to, "", bot
      else viewDomain data.to, data.args[0], bot

viewDomain = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.domain
        bot.say channel, "(#{nick}) #{doc.domain}"
      else
        bot.say channel, "No domain found for #{nick}."
    else
      bot.say channel, "No domain found for #{nick}."

checkUser = (nick, channel, domain, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if validUrl.isUri(domain)
        doc.domain = domain
        changed = true
      else
        bot.say channel, "Invalid URL detected."
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          if changed then bot.say channel, "#{nick}: Saved domain."
    if !doc
      addUser nick, channel, domain, bot

addUser = (nick, channel, domain, bot) ->
  if validUrl.isUri(domain)
    newUser = new User
      nick: nick
      domain: domain
  else
    bot.say channel, "Invalid URL detected."
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      bot.say channel, "#{nick}: Saved domain."

module.exports =
  func: domain
  help: "Save domain: .domain -s domain"
