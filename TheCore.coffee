'use strict'

spinner = require 'elegant-spinner'
chalk   = require 'chalk'

module.exports = class TheCore
  CMD: null
  status: 0
  constructor: (Fallback) ->
    @frame = spinner()
    @fallback = new Fallback() if Fallback

  getStatus: (isFallback=false) =>
    switch @status
      when -1 then chalk.red 'fail'
      when  0 then chalk[unless isFallback then 'yellow' else 'magenta'] @frame()
      when  1 then chalk.green('done') + chalk.gray " (#{@_getStatusInfo()})"
      when  2 then @fallback.getStatus true

  exec: (cb) =>
    @_exec (err, out) =>
      if out
        out = @_processResults out

      if @fallback and (err or not out)
        @status = 2
        @fallback.exec cb

      else if err
        console.error chalk.red(@constructor.name, 'Error:'), err
        @status = -1
        cb err

      else
        @status = 1
        cb null, out
