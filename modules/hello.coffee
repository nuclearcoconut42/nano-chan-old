module.exports =
	func: (bot, data) ->
		if data.args[0]
			bot.say data.to, "Hello, #{data.args[0]}"
		else
			bot.say data.to, "Hello, #{data.from}"
	help: "Says hello!"
