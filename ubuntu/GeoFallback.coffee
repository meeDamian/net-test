'use strict'

{exec}          = require 'child_process'

GeoFallbackCore = require '../GeoFallbackCore'

module.exports = class GeoFallback extends GeoFallbackCore
  CMD: 'iwlist wlan0 scan'
  REGEX: [
    'Cell \\d{1,2} - Address: ([0-F:]{17})'
    'Channel:(\\d*)'
    'Signal level=(-?\\d*)'
    'Encryption key:(on|off)'
    'ESSID:"(.*)"'
  ].join '[\\s\\S]*?'
  getWifis: (cb) ->
    exec @CMD, (err, stdout, stderr) =>
      err ?= stderr
      if err
        cb err
        return

      securityToOpen =
        on: false
        off: true

      regex = new RegExp @REGEX, 'g'
      list = while (match = regex.exec stdout)
        macAddress:               match[1]
        channel:         parseInt match[2]
        signalStrength:  parseInt match[3]
        open:     securityToOpen[ match[4] ]
        ssid:                     match[5]

      cb null, list
