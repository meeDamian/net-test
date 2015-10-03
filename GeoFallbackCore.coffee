'use strict'

request = require 'request'

GeoCore = require './GeoCore'

module.exports = class GeoFallbackCore extends GeoCore
  GOOGLE_MAPS_API_URL: "https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyCbMKtc3LqHHzr8tesiaRSunXVY0V-2vng"
  _askGoogle: (cb, requestBody={}) =>
    request
      url: @GOOGLE_MAPS_API_URL
      method: 'POST'
      json: true
      body: requestBody

    , (err, _, body) =>
      if err
        cb err
        return

      cb null,
        lat: body.location.lat
        lng: body.location.lng
        accuracy: body.accuracy

  _exec: (cb) =>
    unless @getWifis
      @_askGoogle cb

    else
      @getWifis (err, list) =>
        requestBody = {}
        if not err and list
          requestBody.wifiAccessPoints = list

        @_askGoogle cb, requestBody
