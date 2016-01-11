'use strict'

{exec}          = require 'child_process'

GeoFallbackCore = require '../GeoFallbackCore'

module.exports = class GeoFallback extends GeoFallbackCore
  CMD: '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s'
  getWifis: (cb) =>
    exec @CMD, (err, stdout, stderr) ->
      err ?= stderr
      if err
        cb err
        return

      lines = stdout.split '\n'
      between = (from, to) ->
        [
          unless from then 0                else lines[0].indexOf from
          unless to   then lines[0].length  else lines[0].indexOf(to) - 1
        ]

      ranges =
        ssid:     between null        , 'BSSID'
        mac:      between 'BSSID'     , 'RSSI'
        signal:   between 'RSSI'      , 'CHANNEL'
        channel:  between 'CHANNEL'   , 'HT'
        ht:       between 'HT'        , 'CC'
        cc:       between 'CC'        , 'SECURITY'
        security: between 'SECURITY'  , null

      getRange = (line, rangeName) ->
        range = ranges[rangeName]
        line.substring(range[0], range[1]).trim()

      list = for l, i in lines when i > 0 and l isnt ''
        macAddress:               getRange l, 'mac'
        signalStrength: parseInt  getRange l, 'signal'
        channel:        parseInt  getRange l, 'channel'

      cb null, list
