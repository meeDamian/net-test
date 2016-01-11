'use strict'

{exec}    = require 'child_process'

SsidCore  = require '../SsidCore'

module.exports = class Ssid extends SsidCore
  CMD: '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I'
  _exec: (cb) =>
    exec @CMD, (err, stdout, stderr) ->
      err ?= stderr
      if err
        cb err
        return

      o = {}
      for s in stdout.split '\n'
        line = s.trim()
        if line.startsWith 'SSID:'
          o.ssid = s.split(':')[1].trim()
          continue

        if line.startsWith 'link auth:'
          o.open = s.split(':')[1].trim() is 'none'
          continue

        if line.startsWith 'channel:'
          o.channel = s.split(':')[1].trim()
          continue

      cb null, o
