crypto = require 'crypto'

hash = (bot, data) ->
  switch data.args[0]
    when '--md5'
      bot.say data.to, "#{data.from}: #{crypto.createHash('md5').update(data.args[1]).digest 'hex'}"
    when '--sha1'
      bot.say data.to, "#{data.from}: #{crypto.createHash('sha1').update(data.args[1]).digest 'hex'}"
    when '--sha256'
      bot.say data.to, "#{data.from}: #{crypto.createHash('sha256').update(data.args[1]).digest 'hex'}"
    when '--sha512'
      bot.say data.to, "#{data.from}: #{crypto.createHash('sha512').update(data.args[1]).digest 'hex'}"
module.exports =
  func: hash
  help: 'Hash a string [.hash {--md5 | --sha1 | --sha256 | --sha512] [string])'
