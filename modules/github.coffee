userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

github = (bot, data) ->
  if data.args.length == 0
    viewGithub data.to, data.from, bot
  else
    switch data.args[0]
      when "-s", "--set"
        if data.args.length > 1
          checkUser data.from, data.to, data.args[1..].join(" "), bot
        else
          checkUser data.from, data.to, "", bot
      else viewGithub data.to, data.args[0], bot

viewGithub = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.github
        bot.say channel, "(#{nick}) #{doc.github}"
      else
        bot.say channel, "No github found for #{nick}."
    else
      bot.say channel, "No github found for #{nick}."

checkUser = (nick, channel, github, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if validUrl.isUri(github)
        doc.github = github
        changed = true
      else
        bot.say channel, "Invalid URL detected."
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          if changed then bot.say channel, "#{nick}: Saved github."
    if !doc
      addUser nick, channel, github, bot

addUser = (nick, channel, github, bot) ->
  if validUrl.isUri(github)
    newUser = new User
      nick: nick
      github: github
  else
    bot.say channel, "Invalid URL detected."
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      bot.say channel, "#{nick}: Saved github."

module.exports =
  func: github
  help: "Save github: .github -s github"
