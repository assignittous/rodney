cson = require "cson"
aitutils = require("aitutils").aitutils
file = aitutils.file
logger = aitutils.logger

Hints = (knwl) ->



  @languages = 'english': true
  @hints = cson.parseCSONFile "config.rodney.hints.cson"
  console.log "Hints"
  @calls = ()->
    
    text = knwl.words.get('words').join(" ")

    matches = []
    @hints.each (parameter)->
      parameter.synonyms.each (synonym)->
        if text.has(synonym)
          matches.push {
            match: parameter.type
            matchString: synonym
            entity: parameter
            score: synonym.length
          }


    matches

  return
module.exports = Hints

