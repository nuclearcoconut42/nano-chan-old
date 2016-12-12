_ = require 'lodash'
choices = ["Yes.", "No."]

module.exports =
	func: (message, nick) ->
		if ' ' of message
			regex = /(\S+)(( or)|( \|)|( \|\|)|,|$)/g
			options = []
			while match = regex.exec message
				options.push match[1]
			if options.length > 1
				return _.sample options
			else
				return _.sample choices
	help: "Picks a random course of action based on arguments passed"
