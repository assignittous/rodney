console.log "**parse**"
require "sugar"

knwl = require("knwl.js")

cson = require "cson"
aitutils = require("aitutils").aitutils
file = aitutils.file
logger = aitutils.logger

samples = cson.parseCSONFile("samples.cson")
parameterClues = cson.parseCSONFile("config.rodney.hints.cson")

knwlInstance = new knwl("english")
knwlInstance.register('entity', require('./lib/knwl/entity'))
knwlInstance.register('single_date', require('./lib/knwl/single_date'))
knwlInstance.register('date_range', require('./lib/knwl/date_range'))
knwlInstance.register('period', require('./lib/knwl/period'))



samples.each (sample)->
  console.log "=----------------="
  logger.warn sample
  knwlInstance.init(sample)

  entities = knwlInstance.get('entity')
  switch entities.length
    when 0
      logger.error "You're not asking for something I know about"
    when 1
      entity = entities[0].entity
      name = entity.name
      type = entities[0].match
      logger.info name
      if entity.parameterRules?
          # todo- dynamically load
        knwlInstance.register(entity.parameterRules, require("./lib/knwl/#{entity.parameterRules}"))
        runParameters = knwlInstance.get(entity.parameterRules)
        console.log runParameters
      else
        logger.warn "This report has no parameter rules"



    else
      logger.error "Too ambiguous. Ask again"


