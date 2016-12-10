mongoose = require 'mongoose'
Schema = mongoose.Schema

dtopSchema = new Schema
  nick: String
  dtop: String
  tags: [String]

module.exports = dtopSchema
