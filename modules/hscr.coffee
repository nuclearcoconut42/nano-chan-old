userSchema = require "../schemas/user"
validUrl = require "valid-url"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

hscr = (message, nick) ->
  args = message.split(' ')[1..]
  if args.length == 0
    viewHscrs nick
  else
    switch args[0]
      when "-a", "--add"
        if args.length > 1
          if args[1..].every((url) -> validUrl.isUri(url))
            checkUser nick, args[1..]
          else
            "Invalid URL detected."
        else
          "Arguments are required for -a."
      when "-d", "--delete", "--remove"
        if args.length > 1
          deleteHscr nick, args[1..]
        else
          "Arguments are required for -d."
      when "-r", "--replace"
        if data.args.length > 1
          replaceHscr nick, data.args[1..]
        else
          "Arguments are required for -r."
      else viewHscrs args[0]

viewHscrs = (nick) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.hscrs.length == 0
        "No homescreens found for #{nick}."
      else
        i = 0
        say = "(#{nick}) "
        while i < doc.hscrs.length - 1
          say += "[#{i + 1}] #{doc.hscrs[i]} "
          i++
        say += "[#{doc.hscrs.length}] #{doc.hscrs[doc.hscrs.length - 1]}"
        say
    else
      "No homescreens found for #{nick}."

checkUser = (nick, urls) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.hscrs = doc.hscrs.concat urls[..10 - doc.hscrs.length]
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          if urls.length > 1 then "Saved new homescreens."
          else "Saved new homescreen."
    if !doc
      addUser nick, urls

addUser = (nick, urls) ->
  newUser = new User
    nick: nick
    hscrs: urls
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      if urls.length > 1 then "Saved new homescreens."
      else "Saved new homescreen."

deleteHscr = (nick, args) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.hscrs.length == 0
        "You don't have any homescreens to delete."
      else
        if args[0] == "*"
          doc.hscrs = []
          "All homescreens deleted."
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
            "Non-integer value detected."
          else

            doc.save (err) ->
              if deleted > 1
                "Homescreens deleted."
              else if deleted == 1
                "Homescreen deleted."
              else if deleted == 0
                "No homescreens deleted."
              if err then console.error "An error occurred: #{err}"
    else "You don't have any homescreens to delete."

replaceHscr = (nick, args) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occured: #{err}"
    else
      if doc
        if doc.hscrs.length == 0 then "You don't have any homescreens to replace."
        else
          changed = 0
          if args[0] == "*"
            if args[1]
              if validUrl.isUri(args[1])
                doc.hscrs = []
                doc.hscrs.push args[1]
                changed = doc.hscrs.length
              else "Invalid URL detected."
            else "Invalid arguments."
          else
            i = 0
            while i < args.length
              if validUrl.isUri(args[i+1])
                doc.hscrs.set args[i] - 1, args[i+1]
                changed++
              else
                invalid = true
              i += 2
        if invalid then "Invalid URL detected."
        else
          doc.save (err) ->
            if err then console.error "An error occured: #{err}"
            else
              if changed > 1 then "Homescreens changed."
              if changed == 1 then "Homescreen changed."
              else "No homescreens changed."
      else "You don't have any homescreens to delete."

module.exports =
  func: hscr
  help: "Save homescreens: .hscr [-a|--add] [-d|--delete] [-r|--replace] args (see https://github.com/nuclearcoconut42/nano-chan)"
