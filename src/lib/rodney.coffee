# parser.coffee

require 'sugar'

config = require('../lib/configuration').Configuration

periodFinder = require('../lib/rodney_plugins/period')

natural = require('natural')
nlp = require("nlp_compromise")
speak = require("speakeasy-nlp")
exports.Rodney = 

  # identify the entity or entities requrested in the query
  findEntities: (query)->
    matches = []
    dictionary = Object.keys(config.dictionary).sortBy('length', true)

    dictionary.each (item)->
      if query.has(item)
        matches.push item


  parse: (query)->
    output = {}
    console.log "============================="
    console.log "============================="
    console.log query 
    console.log "============================="
    
    # console.log config.entities
    classification = speak.classify(query)

    #console.log classification
    console.log "-----------------------------"
    intent = ""
    switch classification.action
      when "what", "how"
        intent = "metric"
      else
        intent = "other"
    console.log "-----------------------------"
    console.log "intent: #{intent}"

    console.log classification.nouns
    console.log "-----------------------------"
    console.log classification
    console.log "============================="

    output = 
      query: query
      owner: classification.owner || ""
      guessed_entity: classification.subject || ""
      entity_type: intent
      #raw: classification

    ###
    sentences = nlp.sentences(query)
    console.log "#{sentences.length} sentences detected."
    nlp.pos(query).sentences.each (sentence)->
      console.log "sentence: "
      console.log sentence.text()
      console.log "tags"
      console.log sentence.tags()
      console.log "entities"
      console.log nlp.pos(query)

    ###
    return output



    #console.log dictionary

    #foundEntities = findEntities(query)

    #console.log "Found entities:"
    #console.log foundEntities



    #matches = []


    #if matches.length > 0
      #console.log "MATCHES"
      #console.log matches
    #  console.log "Rodney thinks you're looking for #{matches.first()}"
      # todo: handle multiple hits
    #  console.log config.entities[matches.first()]

    #  periodFinder(query)

    #else
    #  console.log "Rodney says I don't know what you're looking for"

    # are there any dictionary matches?

