crypto = require 'crypto'

hash = (message, nick) ->
  args = message.split(' ')[1..]
  pt = args[1..].join ' '
  switch args[0]
    when '--md5'
      return crypto.createHash('md5').update(pt).digest 'hex'
    when '--sha1'
      return crypto.createHash('sha1').update(pt).digest 'hex'
    when '--sha256'
      return crypto.createHash('sha256').update(pt).digest 'hex'
    when '--sha512'
      return crypto.createHash('sha512').update(pt).digest 'hex'
module.exports =
  func: hash
  help: 'Hash a string [.hash {--md5 | --sha1 | --sha256 | --sha512] [string])'
