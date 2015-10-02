'use strict'

spinner = require 'elegant-spinner'
chalk   = require 'chalk'

module.exports = class TheCore
  CMD: null
  status: 0
  constructor: -> @frame = spinner()
  getStatus: ->
    switch @status
      when  0 then chalk.yellow @frame()
      when  1 then chalk.green('done') + chalk.gray " (#{@_getStatusInfo()})"
      when -1 then chalk.red 'fail'

  exec: (cb) =>
    @_exec (err, out) =>
      if err
        console.error chalk.red(@constructor.name, 'Error:'), err
        @status = -1
        cb err

      else
        @status = 1
        out = @_processResults out
        cb null, out
