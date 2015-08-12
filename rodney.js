#!/usr/bin/env node
var aitutils, cson, file, knwl, knwlInstance, logger, parameterClues, samples;

console.log("**parse**");

require("sugar");

knwl = require("knwl.js");

cson = require("cson");

aitutils = require("aitutils").aitutils;

file = aitutils.file;

logger = aitutils.logger;

samples = cson.parseCSONFile("samples.cson");

parameterClues = cson.parseCSONFile("config.rodney.hints.cson");

knwlInstance = new knwl("english");

knwlInstance.register('entity', require('./lib/knwl/entity'));

knwlInstance.register('single_date', require('./lib/knwl/single_date'));

knwlInstance.register('date_range', require('./lib/knwl/date_range'));

knwlInstance.register('period', require('./lib/knwl/period'));

samples.each(function(sample) {
  var entities, entity, name, runParameters, type;
  console.log("=----------------=");
  logger.warn(sample);
  knwlInstance.init(sample);
  entities = knwlInstance.get('entity');
  switch (entities.length) {
    case 0:
      return logger.error("You're not asking for something I know about");
    case 1:
      entity = entities[0].entity;
      name = entity.name;
      type = entities[0].match;
      logger.info(name);
      if (entity.parameterRules != null) {
        knwlInstance.register(entity.parameterRules, require("./lib/knwl/" + entity.parameterRules));
        return runParameters = knwlInstance.get(entity.parameterRules);
      } else {
        return logger.warn("This report has no parameter rules");
      }
      break;
    default:
      return logger.error("Too ambiguous. Ask again");
  }
});
