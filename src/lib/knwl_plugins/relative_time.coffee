require 'sugar'
nlp = require "nlp_compromise"

RelativeTime = (knwlInstance) ->
  @languages = english: true

  @calls = ->
    words = knwlInstance.words.get('words')
    #get the String as an array of words
    resultsArray = []

    common_relative_modifiers = [
      "next"
      "last"
      "past"
    ]

    common_relative_periods = [
      "yesterday"
      "today"
      "week"
      "month"
      "quarter"
      "half"
      "year"
    ]

    matches = common_relative_periods.intersect(words)


    console.log knwlInstance


    #console.log knwlInstance.words.linkWordsCasesensitive
    #console.log nlp.value(words.join(" "))

    #console.log "relative time"
    #console.log words
    ###

    Parser Code

    ###
    results = words

    results

  return

module.exports = RelativeTime