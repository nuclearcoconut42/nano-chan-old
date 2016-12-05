mongoose = require 'mongoose'
Schema = mongoose.Schema

userSchema = new Schema
	nick: String,
	dtops: [String],
	distro: String,
	github: String,
	domain: String,
	anilist: String,
	hws: [String],
	waifu: String,
	hscrs: [String],
	selfies: [String]
module.exports = userSchema
