dice = (bot, data) ->
	sum = 0
	for roll in data.args
		parsed = roll.split 'd'
		sum += Math.floor(Math.random() * parsed[1]) for i in [1..parsed[0]]
	bot.say data.to, "#{data.from}: #{sum}"
module.exports =
	func: dice
	help: "Rolls dice using standard notation: (3d4 rolls three four-sided dice)"
