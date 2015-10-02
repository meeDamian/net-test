'use strict'

GeoCore = require '../GeoCore'
{exec}  = require 'child_process'

module.exports = class Geo extends GeoCore
  CMD: [
    "#{__dirname}/whereami"
    'head -n2'
    "sed 's/Latitude: //'"
    "sed 's/Longitude: //'"
  ].join ' | '
  _exec: (cb) =>
    exec @CMD, (err, stdout, stderr) =>
      err ?= stderr
      if err
        cb err
        return

      [lat, lng] = stdout.split '\n'
        .map parseFloat
        .splice 0, 2

      cb null,
        lat: lat
        lng: lng
