'use strict'

{exec}  = require 'child_process'

GeoCore = require '../GeoCore'

module.exports = class Geo extends GeoCore
  CMD: [
    "#{__dirname}/whereami"
    'head -n3'
    "sed 's/Latitude: //'"
    "sed 's/Longitude: //'"
    "sed 's/Accuracy (m): //'"

  ].join ' | '
  _exec: (cb) =>
    exec @CMD, (err, stdout, stderr) =>
      err ?= stderr
      if err
        cb err
        return

      [lat, lng, accuracy] = stdout.split '\n'
        .map parseFloat
        .splice 0, 3

      cb null,
        lat: lat
        lng: lng
        accuracy: accuracy
