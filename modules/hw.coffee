userSchema = require "../schemas/user"
validUrl = require "valid-url"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

hw = (bot, data) ->
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
    if doc
      if doc.hws.length == 0
        bot.say channel, "No handwritings found for #{nick}."
      else
        i = 0
        say = "(#{nick}) "
        while i < doc.hws.length - 1
          say += "[#{i + 1}] #{doc.hws[i]} "
          i++
        say += "[#{doc.hws.length}] #{doc.hws[doc.hws.length - 1]}"
        bot.say channel, say
    else
      bot.say channel, "No handwritings found for #{nick}."

checkUser = (nick, channel, urls, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.hws = doc.hws.concat urls[..10 - doc.hws.length]
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          if urls.length > 1 then bot.say channel, "#{nick}: Saved new handwritings."
          else  bot.say channel, "#{nick}: Saved new handwriting."
    if !doc
      addUser nick, channel, urls, bot

addUser = (nick, channel, urls, bot) ->
  newUser = new User
    nick: nick
    hws: urls
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      if urls.length > 1 then bot.say channel, "#{nick}: Saved new handwritings."
      else bot.say channel, "#{nick}: Saved new handwriting."

deleteDtop = (nick, channel, args, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.hws.length == 0
        bot.say channel, "#{nick}: You don't have any handwritings to delete."
      else
        if args[0] == "*"
          doc.hws = []
          bot.say channel, "#{nick}: All handwritings deleted."
        else
          deleted = 0
          for arg in args
            hws = doc.hws
            if arg.match /:/ then slice = arg.split ':'
            else if arg.match /\.\./ then slice = arg.split '..'
            else if arg.match /\-/ then slice = arg.split '-'
            if slice
              if slice.every((index) -> ((!isNaN index) && ((parseInt index) == (Math.floor index)) index < doc.hws.length))
                doc.hws.splice slice[0]-1, slice[1]-slice[0]
              else invalid = true
            else
              if (!isNaN arg) && ((parseInt arg) == (Math.floor arg))
                doc.hws.splice arg - deleted, 1
                deleted++
              else
                invalid = true
          if invalid
            bot.say channel, "#{nick}: Non-integer value detected."
          else

            doc.save (err) ->
              if deleted > 1
                bot.say channel, "#{nick}: Handwritings deleted."
              else if deleted == 1
                bot.say channel, "#{nick}: Handwriting deleted."
              else if deleted == 0
                bot.say channel, "#{nick}: No handwritings deleted."
              if err then console.error "An error occurred: #{err}"
    else bot.say channel, "#{nick}: You don't have any handwritings to delete."

replaceDtop = (nick, channel, args, bot) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occured: #{err}"
    else
      if doc
        if doc.hws.length == 0 then bot.say channel, "#{nick}: You don't have any handwritings to replace."
        else
          changed = 0
          if args[0] == "*"
            if args[1]
              if validUrl.isUri(args[1])
                doc.hws = []
                doc.hws.push args[1]
                changed = doc.hws.length
              else
                bot.say channel, "#{nick}: Invalid URL detected."
            else
              bot.say channel, "#{nick}: Invalid arguments."
          else
            i = 0
            while i < args.length
              if validUrl.isUri(args[i+1])
                doc.hws.set args[i] - 1, args[i+1]
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
                bot.say channel, "#{nick}: Handwritings changed."
              if changed == 1
                bot.say channel, "#{nick}: Handwriting changed."
              else
                bot.say channel, "#{nick}: No handwritings changed."
      else bot.say channel, "#{nick}: You don't have any handwritings to delete."

module.exports =
  func: hw
  help: "Save handwritings: .hw [-a|--add] [-d|--delete] [-r|--replace] args (see https://github.com/nuclearcoconut42/nano-chan)"
