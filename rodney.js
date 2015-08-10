#!/usr/bin/env node
var aitutils, cson, file, knwl, knwlInstance, logger, parameterClues, parameterSearch, samples;

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

knwlInstance.register('entities', require('./lib/knwl/entities'));

knwlInstance.register('dates', require('./lib/knwl/dates'));

parameterSearch = function(text, parameters) {};

samples.each(function(sample) {
  var dates, entities;
  console.log("=----------------=");
  logger.warn(sample);
  knwlInstance.init(sample);
  entities = knwlInstance.get('entities');
  console.log("Dictionary Matches");
  console.log("=----------------=");
  console.log(entities);
  dates = knwlInstance.get('dates');
  console.log("Parameter Matches");
  console.log("=----------------=");
  return console.log(dates);

  /*
  loadedEntities = cson.parseCSONFile "config.rodney.dictionary.cson"
    #console.log data
  console.log "********"
  #console.log matchDate(sample).date()
  console.log "********"
  
  parameterSearch sample.toLowerCase(), parameterClues
  #console.log e
  
  
  
  console.log "------"
  console.log " "
   * sample.has
   */
});
