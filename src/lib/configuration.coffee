# configuration.coffee


CSON = require('cson')
cwd = process.env.PWD || process.cwd()

exports.Configuration = {

  current: {}

  # Load config file

  cwd: ()->
    process.env.PWD || process.cwd()

  load: ()->
    @current = CSON.parseCSONFile("#{@cwd()}/config.rodney.cson")

  init: ()->
    console.log "init"
    @load()
    return @
  # Upgrade config file



}.init()