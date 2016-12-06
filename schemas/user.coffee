mongoose = require 'mongoose'
Schema = mongoose.Schema

userSchema = new Schema
  nick: String,
  dtops: [String],
  distro: String,
  github: String,
  domain: String,
  hws: [String],
  waifu: String,
  hscrs: [String],
	selfies: [String],
	mal: String,
	lastfm: String
module.exports = userSchema
