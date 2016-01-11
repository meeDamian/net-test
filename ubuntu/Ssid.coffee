'use strict'

SsidCore  = require '../SsidCore'
{exec}    = require 'child_process'

module.exports = class Ssid extends SsidCore
  _exec: (cb) ->
    cb null,
      ssid: 'fake wifi'
      open: true
      channel: 1
