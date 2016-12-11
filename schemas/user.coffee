mongoose = require 'mongoose'
Schema = mongoose.Schema

dtopSchema = new Schema
  dtop: String
  tags: String

userSchema = new Schema
	nick: String
  dtops: [dtopSchema]
	distro: String
	github: String
	domain: String
	anilist: String
	hws: [String]
	waifu: String
	hscrs: [String]
	selfies: [String]
	lastfm: String
	wm: String
module.exports = userSchema
