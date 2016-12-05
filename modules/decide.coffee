choices = ["Yes.", "No."]
choice = (args) ->
  args[Math.floor Math.random() * args.length]

parse = (bot, data) ->
	args = data.args.join ' '
	if !(args)
		bot.say data.to, "#{data.from}: #{choices[Math.floor Math.random() * 2]}"
	else if args.match /or/
		bot.say data.to, "#{data.from}: #{choice args.split ' or '}"
	else if args.match /\|/
		bot.say data.to, "#{data.from}: #{choice args.split ' | '}"
	else if args.match /\|\|/
		bot.say data.to, "#{data.from}: #{choice args.split ' || '}"
	else if args.match /,$/
		bot.say data.to, "#{data.from}: #{choice args.split ', '}"
	else if args.match /\s/
		bot.say data.to, "#{data.from}: #{choice args.split ' '}"

module.exports =
  func: parse
	help: "Picks a random course of action based on arguments passed"
