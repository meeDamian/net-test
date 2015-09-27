'use strict'

spinner = require 'elegant-spinner'
{Parse} = require 'parse/node'
{exec}  = require 'child_process'
logger  = require 'log-update'
async   = require 'async'
chalk   = require 'chalk'
meow    = require 'meow'

tap = (o, fn) -> fn(o); o
merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs

cli = meow
  help: [
    'Usage'
    '  $ net-test'
    ''
    'Options'
    '  --no-parse  Skip uploading results to parse'
    ''
  ]

class Geo
  CMD: [
    "#{__dirname}/whereami"
    'head -n2'
    "sed 's/Latitude: //'"
    "sed 's/Longitude: //'"
  ].join ' | '
  GOOGLE_MAPS_LINK: "https://www.google.com/maps/@%lat%,%lng%,%zoom%z"
  DEFAULT_ZOOM: 15
  status: 0
  constructor: -> @frame = spinner()
  getStatus: ->
    switch @status
      when  0 then chalk.yellow @frame()
      when  1 then chalk.green('done') + chalk.gray " (#{@lat}, #{@lng})"
      when -1 then chalk.red 'fail'

  exec: (cb) =>
    exec @CMD, (err, stdout, stderr) =>
      err ?= stderr
      if err
        console.error "GEO Error:", err
        @status = -1
        cb err
        return

      [@lat, @lng] = stdout.split '\n'
        .map parseFloat
        .splice 0, 2

      @status = 1
      cb null,
        lat: @lat
        lng: @lng
        url: @GOOGLE_MAPS_LINK.replace '%zoom%', @DEFAULT_ZOOM
          .replace '%lat%', @lat
          .replace '%lng%', @lng

class Net
  CMD: "#{__dirname}/node_modules/.bin/speed-test --json"
  status: 0
  constructor: -> @frame = spinner()
  getStatus: ->
    switch @status
      when  0 then chalk.yellow @frame()
      when  1 then chalk.green('done') + chalk.gray " (#{@dl}/#{@up} Mbps)"
      when -1 then chalk.red 'fail'

  exec: (cb) =>
    exec @CMD, (err, stdout, stderr) =>
      err ?= stderr
      if err
        console.error "NET Error:", err
        @status = -1
        cb err
        return

      info = JSON.parse stdout
      @status = 1
      @dl = info.download
      @up = info.upload
      cb null, info

class Ssid
  CMD: '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I'
  status: 0
  constructor: -> @frame = spinner()
  getStatus: ->
    switch @status
      when  0 then chalk.yellow @frame()
      when  1 then chalk.green('done') + chalk.gray " (#{@ssid})"
      when -1 then chalk.red 'fail'

  exec: (cb) =>
    exec @CMD, (err, stdout, stderr) =>
      err ?= stderr
      if err
        console.error "SSID Error:", err
        @status = -1
        cb err
        return

      o = {}
      for s in stdout.split '\n'
        line = s.trim()
        if line.startsWith 'SSID:'
          @ssid = o.ssid = s.split(':')[1].trim()
          continue

        if line.startsWith 'link auth:'
          o.open = s.split(':')[1].trim() is 'none'
          continue

        if line.startsWith 'channel:'
          o.channel = s.split(':')[1].trim()
          continue

      @status = 1
      cb null, o

class Test
  PARSE_ID: '5mhCAqwUlwT6tHrC0PmYda73KzAzQ0eSoFbIi6WV'
  PARSE_KEY: 'slNZDFWnonWXkam1XjTRhSqE0fwdJo111cEjZ2lm'
  PARSE_CLASS: 'WiFi'
  initParse: -> Parse.initialize @PARSE_ID, @PARSE_KEY
  constructor: ->
    @startTime = +new Date

    @initParse()

    @net = new Net()
    @geo = new Geo()
    @ssid = new Ssid()

    @intervalId = setInterval @render, 50

    async.parallel
      net:  @net.exec
      geo:  @geo.exec
      ssid: @ssid.exec

    , @results

  processForParse: (obj) ->
    geoPoint = new Parse.GeoPoint
      latitude: obj.lat
      longitude: obj.lng

    ssid:         obj.ssid
    download:     obj.download
    upload:       obj.upload
    ping:         obj.ping
    open:         obj.open
    channel:      obj.channel
    location:     geoPoint
    locationUrl:  obj.url
    ts:           obj.ts
    runtime:      obj.runtime

  uploadResults: (obj) ->
    @parseFrame = spinner()
    parseIntervalId = setInterval @renderParse, 50

    WiFi = Parse.Object.extend 'WiFi'
    wiFi = new WiFi()
    wiFi.save @processForParse(obj),
      success: (response) =>
        clearInterval parseIntervalId
        @renderParse response.id

      error: (something, err) =>
        console.log 'error', something, err
        clearInterval parseIntervalId

  results: (err, res) =>
    clearInterval @intervalId
    @render()

    final = merge res.net, res.geo, res.ssid

    final.ts = Date()
    final.runTime = +new Date - @startTime

    console.log "\nResults: #{JSON.stringify(final, null, '  ')}\n"

    unless cli.flags.parse is false
      console.log "\n\n\n\n"
      @uploadResults final

  render: =>
    logger [
      ''
      '      SSID: ' + @ssid.getStatus()
      '  location: ' +  @geo.getStatus()
      '     speed: ' +  @net.getStatus()
    ].join '\n'

  renderParse: (id=null) =>
    status = if id isnt null
      chalk.green('done') + chalk.gray " (id: #{id})"
    else
      chalk.magenta @parseFrame()

    logger chalk.bold('Uploading results to Parse: ') + status + '\n'

new Test()
