cson = require "cson"
aitutils = require("aitutils").aitutils
file = aitutils.file
logger = aitutils.logger
require 'sugar'
Sherlock = require "../../lib/sherlock"
IncomeStatement = (knwl) ->



  @languages = 'english': true
  @dictionary = cson.parseCSONFile "config.rodney.dictionary.cson"

  @calls = ()->
    
    text = knwl.words.get('words').join(" ")
    sherlocked = Sherlock.parse(text)

    if sherlocked.startDate?
      console.log "---sherlock"
      console.log JSON.stringify(sherlocked,null,2)
      if sherlocked.hasYear?
        console.log sherlocked.hasYear
      console.log Date.create(sherlocked.startDate)

    console.log "income statement rules runnign"
    # rules, single date

    # get the date 


    # get the period

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



    return [
      {
        date: "today"
      }
      {
        period: "year"
      }

    ]

  return
module.exports = IncomeStatement

