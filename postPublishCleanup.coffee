fs = require 'fs-extended'

EXT_JS = '.js'
EXT_MAP = '.map'

#
# Is called after `npm publish`, and removes all unnecessary compiled js files
#
fs.listAll '.',
  recursive: true
  filter: (itemPath) ->
    return false if /node_modules|\.git/.test itemPath
    return /\.map$/.test itemPath
  map: (itemPath) -> itemPath.replace '.js.map', ''

, (err, list) ->
  for file in list
    console.log "Removing #{file + EXT_JS}[#{EXT_MAP}]..."
    fs.deleteFile file + EXT_JS
    fs.deleteFile file + EXT_JS + EXT_MAP
