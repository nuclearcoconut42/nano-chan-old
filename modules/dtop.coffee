userSchema = require "../schemas/user"
validUrl = require "valid-url"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

dtop = (bot, data) ->
  if data.args.length == 0
    viewDtops data.to, data.from, bot
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
          deleteDtop data.from, data.to, data.args[1..], bot
        else
          bot.say data.to, "#{data.from}: Arguments are required for -d."
      when "-r", "--replace"
        if data.args.length > 1
          replaceDtop data.from, data.to, data.args[1..], bot
        else
          bot.say data.to, "#{data.from}: Arguments are required for -r."
      else viewDtops data.to, data.args[0], bot

viewDtops = (channel, nick, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
		console.log doc
		if doc
      if doc.dtops.length == 0
        bot.say channel, "No desktops found for #{nick}."
      else
        i = 0
        say = "(#{nick}) "
        while i < doc.dtops.length - 1
          say += "[#{i + 1}] #{doc.dtops[i]} "
          i++
        say += "[#{doc.dtops.length}] #{doc.dtops[doc.dtops.length - 1]}"
        bot.say channel, say
    else
      bot.say channel, "No desktops found for #{nick}."

checkUser = (nick, channel, urls, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.dtops = doc.dtops.concat urls[..10 - doc.dtops.length]
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          if urls.length > 1 then bot.say channel, "#{nick}: Saved new desktops."
          else  bot.say channel, "#{nick}: Saved new desktop."
    if !doc
      addUser nick, channel, urls, bot

addUser = (nick, channel, urls, bot) ->
  newUser = new User
    nick: nick
    dtops: urls
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      if urls.length > 1 then bot.say channel, "#{nick}: Saved new desktops."
      else bot.say channel, "#{nick}: Saved new desktop."

deleteDtop = (nick, channel, args, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.dtops.length == 0
        bot.say channel, "#{nick}: You don't have any desktops to delete."
      else
        if args[0] == "*"
          doc.dtops = []
          bot.say channel, "#{nick}: All desktops deleted."
        else
          deleted = 0
          for arg in args
            dtops = doc.dtops
            if arg.match /:/ then slice = arg.split ':'
            else if arg.match /\.\./ then slice = arg.split '..'
            else if arg.match /\-/ then slice = arg.split '-'
            if slice
              if slice.every((index) -> ((!isNaN index) && ((parseInt index) == (Math.floor index)) index < doc.dtops.length))
                doc.dtops.splice slice[0]-1, slice[1]-slice[0]
              else invalid = true
            else
              if (!isNaN arg) && ((parseInt arg) == (Math.floor arg))
                doc.dtops.splice arg - deleted, 1
                deleted++
              else
                invalid = true
          if invalid
            bot.say channel, "#{nick}: Non-integer value detected."
          else

            doc.save (err) ->
              if deleted > 1
                bot.say channel, "#{nick}: Desktops deleted."
              else if deleted == 1
                bot.say channel, "#{nick}: Desktop deleted."
              else if deleted == 0
                bot.say channel, "#{nick}: No desktops deleted."
              if err then console.error "An error occurred: #{err}"
    else bot.say channel, "#{nick}: You don't have any desktops to delete."

replaceDtop = (nick, channel, args, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occured: #{err}"
    else
      if doc
        if doc.dtops.length == 0 then bot.say channel, "#{nick}: You don't have any desktops to replace."
        else
          changed = 0
          if args[0] == "*"
            if args[1]
              if validUrl.isUri(args[1])
                doc.dtops = []
                doc.dtops.push args[1]
                changed = doc.dtops.length
              else
                bot.say channel, "#{nick}: Invalid URL detected."
            else
              bot.say channel, "#{nick}: Invalid arguments."
          else
            i = 0
            while i < args.length
              if validUrl.isUri(args[i+1])
                doc.dtops.set args[i] - 1, args[i+1]
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
                bot.say channel, "#{nick}: Desktops changed."
              if changed == 1
                bot.say channel, "#{nick}: Desktop changed."
              else
                bot.say channel, "#{nick}: No desktops changed."
      else bot.say channel, "#{nick}: You don't have any desktops to delete."

module.exports =
  func: dtop
  help: "Save desktops: .dtop [-a|--add] [-d|--delete] [-r|--replace] args (see https://github.com/nuclearcoconut42/nano-chan)"
