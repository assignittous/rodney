# configuration.coffee


CSON = require('cson')
cwd = process.env.PWD || process.cwd()

exports.Configuration = {

  current: {}
  dictionary: {}
  entities: {}

  # Load config file

  cwd: ()->
    process.env.PWD || process.cwd()

  load: ()->
    @current = CSON.parseCSONFile("#{@cwd()}/config.rodney.cson")
    @dictionary = CSON.parseCSONFile("#{@cwd()}/config.rodney.dictionary.cson")
    @entities = CSON.parseCSONFile("#{@cwd()}/config.rodney.entities.cson")
  init: ()->
    console.log "init"
    @load()
    return @
  # Upgrade config file



}.init()