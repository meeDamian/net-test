'use strict'

TheCore = require './TheCore'

module.exports = class GeoCore extends TheCore
  GOOGLE_MAPS_LINK: "https://www.google.com/maps/@%lat%,%lng%,%zoom%z"
  DEFAULT_ZOOM: 15
  _processResults: (out) =>
    @lat = out.lat
    @lng = out.lng

    out.url = @GOOGLE_MAPS_LINK.replace '%zoom%', @DEFAULT_ZOOM
      .replace '%lat%', out.lat
      .replace '%lng%', out.lng

    out

  _getStatusInfo: => "#{@lat}, #{@lng}"
