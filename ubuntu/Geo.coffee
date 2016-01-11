'use strict'

{exec}  = require 'child_process'

GeoCore = require '../GeoCore'

module.exports = class Geo extends GeoCore
  _exec: (cb) ->
    cb null,
      lat: null
      lng: null
      accuracy: null
