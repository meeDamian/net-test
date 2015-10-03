'use strict'

TheCore = require './TheCore'

#
# Extend this object as and return `out` object with following fields:
#  **lat**      - [Number] Latitude of current location
#  **lng**      - [Number] Longitude of current location
#  **accuracy** - [Number] Predicted accuracy of returned location
#
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
