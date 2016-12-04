mongoose = require 'mongoose'
Schema = mongoose.Schema

userSchema = new Schema
  nick: String,
  dtops: [String],
  distro: String,
  github: String,
  domain: String,
  hws: [String],
  waifu: String
module.exports = userSchema
