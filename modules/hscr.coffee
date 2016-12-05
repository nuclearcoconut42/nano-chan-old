userSchema = require "../schemas/user"
validUrl = require "valid-url"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

hscr = (bot, data) ->
  if data.args.length == 0
    viewHscrs data.to, data.from, bot
  else
    switch data.args[0]
      when "-a", "--add"
        if data.args.length > 1
          if data.args[1..].every((url) -> validUrl.isUri(url))
            checkUser data.from, data.to, data.args[1..], bot
          else
            bot.say data.to, "#{data.from}: Invalid URL detected."
        else
          bot.say data.to, "#{data.from}: Arguments are required for -a."
      when "-d", "--delete", "--remove"
        if data.args.length > 1
          deleteHscr data.from, data.to, data.args[1..], bot
        else
          bot.say data.to, "#{data.from}: Arguments are required for -d."
      when "-r", "--replace"
        if data.args.length > 1
          replaceHscr data.from, data.to, data.args[1..], bot
        else
          bot.say data.to, "#{data.from}: Arguments are required for -r."
      else viewHscrs data.to, data.args[0], bot

viewHscrs = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.hscrs.length == 0
        bot.say channel, "No homescreens found for #{nick}."
      else
        i = 0
        say = "(#{nick}) "
        while i < doc.hscrs.length - 1
          say += "[#{i + 1}] #{doc.hscrs[i]} "
          i++
        say += "[#{doc.hscrs.length}] #{doc.hscrs[doc.hscrs.length - 1]}"
        bot.say channel, say
    else
      bot.say channel, "No homescreens found for #{nick}."

checkUser = (nick, channel, urls, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.hscrs = doc.hscrs.concat urls[..10 - doc.hscrs.length]
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          if urls.length > 1 then bot.say channel, "#{nick}: Saved new homescreens."
          else  bot.say channel, "#{nick}: Saved new homescreen."
    if !doc
      addUser nick, channel, urls, bot

addUser = (nick, channel, urls, bot) ->
  newUser = new User
    nick: nick
    hscrs: urls
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      if urls.length > 1 then bot.say channel, "#{nick}: Saved new homescreens."
      else bot.say channel, "#{nick}: Saved new homescreen."

deleteHscr = (nick, channel, args, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.hscrs.length == 0
        bot.say channel, "#{nick}: You don't have any homescreens to delete."
      else
        if args[0] == "*"
          doc.hscrs = []
          bot.say channel, "#{nick}: All homescreens deleted."
        else
          deleted = 0
          for arg in args
            hscrs = doc.hscrs
            if arg.match /:/ then slice = arg.split ':'
            else if arg.match /\.\./ then slice = arg.split '..'
            else if arg.match /\-/ then slice = arg.split '-'
            if slice
              if slice.every((index) -> ((!isNaN index) && ((parseInt index) == (Math.floor index)) index < doc.hscrs.length))
                doc.hscrs.splice slice[0]-1, slice[1]-slice[0]
              else invalid = true
            else
              if (!isNaN arg) && ((parseInt arg) == (Math.floor arg))
                doc.hscrs.splice arg - deleted, 1
                deleted++
              else
                invalid = true
          if invalid
            bot.say channel, "#{nick}: Non-integer value detected."
          else

            doc.save (err) ->
              if deleted > 1
                bot.say channel, "#{nick}: Homescreens deleted."
              else if deleted == 1
                bot.say channel, "#{nick}: Homescreen deleted."
              else if deleted == 0
                bot.say channel, "#{nick}: No homescreens deleted."
              if err then console.error "An error occurred: #{err}"
    else bot.say channel, "#{nick}: You don't have any homescreens to delete."

replaceHscr = (nick, channel, args, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occured: #{err}"
    else
      if doc
        if doc.hscrs.length == 0 then bot.say channel, "#{nick}: You don't have any homescreens to replace."
        else
          changed = 0
          if args[0] == "*"
            if args[1]
              if validUrl.isUri(args[1])
                doc.hscrs = []
                doc.hscrs.push args[1]
                changed = doc.hscrs.length
              else
                bot.say channel, "#{nick}: Invalid URL detected."
            else
              bot.say channel, "#{nick}: Invalid arguments."
          else
            i = 0
            while i < args.length
              if validUrl.isUri(args[i+1])
                doc.hscrs.set args[i] - 1, args[i+1]
                changed++
              else
                invalid = true
              i += 2
        if invalid then bot.say channel, "Invalid URL detected."
        else
          doc.save (err) ->
            if err then console.error "An error occured: #{err}"
            else
              if changed > 1
                bot.say channel, "#{nick}: Homescreens changed."
              if changed == 1
                bot.say channel, "#{nick}: Homescreen changed."
              else
                bot.say channel, "#{nick}: No homescreens changed."
      else bot.say channel, "#{nick}: You don't have any homescreens to delete."

module.exports =
  func: hscr
  help: "Save homescreens: .hscr [-a|--add] [-d|--delete] [-r|--replace] args (see https://github.com/nuclearcoconut42/nano-chan)"
