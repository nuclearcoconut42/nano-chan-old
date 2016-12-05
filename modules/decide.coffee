choices = ["Yes.", "No."]
choice = (args) ->
  if args.length == 1 then choices[Math.floor Math.random() * 2]
  else args[Math.floor Math.random() * args.length]

module.exports =
  func: (bot, data) ->
    console.log JSON.stringify data.args
    if data.args.length < 1
      bot.say data.to, "#{data.from}: #{choice data.args}"
    else if data.args[1] == 'or'
      console.log data.args.join(' ').split ' or '
      bot.say data.to, "#{data.from}: #{choice data.args.join(' ').split ' or '}"
    else if data.args[1] == '|'
      bot.say data.to, "#{data.from}: #{choice data.args.join(' ').split ' | '}"
    else if data.args[1] == '||'
      bot.say data.to, "#{data.from}: #{choice data.args.join(' ').split ' || '}"
    else if data.args[0].match /,$/
      bot.say data.to, "#{data.from}: #{choice data.args.join(' ').split ', '}"
    else
      bot.say data.to, "#{data.from}: #{choice data.args}"
  help: "Picks a random course of action based on arguments passed"
