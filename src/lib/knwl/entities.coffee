cson = require "cson"
aitutils = require("aitutils").aitutils
file = aitutils.file
logger = aitutils.logger

Entities = (knwl) ->



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
    matches

  return
module.exports = Entities

