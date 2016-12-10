choices = ["Yes.", "No."]
choice = (args) ->
  args[Math.floor Math.random() * args.length]

module.exports =
  func: (bot, data) ->
    if data.args.length > 0
      if data.args[1] == 'or'
        console.log data.args.join(' ').split ' or '
        bot.say data.to, "#{data.from}: #{choice data.args.join(' ').split ' or '}"
      else if data.args[1] == '|'
        bot.say data.to, "#{data.from}: #{choice data.args.join(' ').split ' | '}"
      else if data.args[1] == '||'
        bot.say data.to, "#{data.from}: #{choice data.args.join(' ').split ' || '}"
      else if data.args[0].match /,\s/
        bot.say data.to, "#{data.from}: #{choice data.args.join(' ').split ', '}"
      else
        bot.say data.to, "#{data.from}: #{choice choices}"
  help: "Picks a random course of action based on arguments passed"
