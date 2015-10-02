'use strict'

TheCore = require './TheCore'
{exec}  = require 'child_process'

module.exports = class NetCore extends TheCore
  CMD: "#{__dirname}/node_modules/.bin/speed-test --json"
  _exec: (cb) =>
    exec @CMD, (err, stdout, stderr) =>
      err ?= stderr
      if err
        cb err
        return

      cb null, JSON.parse stdout

  _processResults: (out) =>
    @dl = out.download
    @up = out.upload

    out

  _getStatusInfo: => "#{@dl}/#{@up} Mbps"
