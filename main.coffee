'use strict'

spinner = require 'elegant-spinner'
{Parse} = require 'parse/node'
{exec}  = require 'child_process'
logger  = require 'log-update'
async   = require 'async'
chalk   = require 'chalk'
meow    = require 'meow'
os      = require 'os'

Net     = require './NetCore'

prefix = switch os.platform()
  when 'darwin' then 'mac'
  when 'win32'  then null
  when 'linux'  then null
  else null

if prefix is null
  console.log chalk.red [
    ''
    '  Your operating system is currently not supported. PRs welcome at https://goo.gl/clvSD4'
    ''
  ].join '\n'
  process.exit 1

Ssid = require "./#{prefix}/Ssid"
try
  Ssid2 = require "./#{prefix}/SsidFallback"

Geo  = require "./#{prefix}/Geo"
try Geo2 = require "./#{prefix}/GeoFallback"
catch ignore
  try Geo2 = require './GeoFallbackCore'


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

class Test
  PARSE_ID: '5mhCAqwUlwT6tHrC0PmYda73KzAzQ0eSoFbIi6WV'
  PARSE_KEY: 'slNZDFWnonWXkam1XjTRhSqE0fwdJo111cEjZ2lm'
  PARSE_CLASS: 'WiFi'
  initParse: -> Parse.initialize @PARSE_ID, @PARSE_KEY
  constructor: ->
    @startTime = +new Date

    @initParse()

    @ssid = new Ssid Ssid2
    @geo  = new Geo Geo2
    @net  = new Net()

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

    if err
      console.error chalk.red [
        ''
        '  Some of the required tests have failed. Try again later or quickly reinstall your system.'
        ''
      ].join '\n'
      return

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
