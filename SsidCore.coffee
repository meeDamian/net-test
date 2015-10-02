'use strict'

TheCore = require './TheCore'

#
# Extend this object and return `out` object with following fields:
#  **ssid**   - [String] name of the WiFi network
#  **open**   - [Boolean] is the network secured or open
#  **channel  - [Number] what channel the WiFi operates on
#
module.exports = class SsidCore extends TheCore
  _processResults: (out) =>
    @ssid = out.ssid
    out

  _getStatusInfo: => "#{@ssid}"
