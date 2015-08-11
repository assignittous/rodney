cson = require "cson"
aitutils = require("aitutils").aitutils
file = aitutils.file
logger = aitutils.logger
require 'sugar'

Entity = (knwl) ->



  @languages = 'english': true
  @dictionary = cson.parseCSONFile "config.rodney.dictionary.cson"

  @calls = ()->
    
    text = knwl.words.get('words').join(" ")

    matches = []
    @dictionary.each (entity)->
      synonyms = entity.synonyms.clone().add(entity.name)
      synonyms.each (synonym)->
        if text.has(synonym)
          matches.push {
            match: entity.type
            entity: entity
            score: synonym.length
          }



    return matches.max('score', true)

  return
module.exports = Entity

