#lib = require "knwl.js"
nlp = require "nlp_compromise"
natural = require "natural"
require "sugar"

exports.knwl = {

  test: ()->
    # console.log "Howdy"
    #instance = new lib('english')
    #instance.register('relative_time', require('../lib/knwl_plugins/relative_time'));
    parseString = "sales for Canada and bahamas between last year and this year"

    classifier = new natural.BayesClassifier()


    classifier.addDocument('the qqqq statement', 'report')
    #classifier.addDocument('buy the q\'s', 'buy')
    #classifier.addDocument('short gold', 'sell')
    #classifier.addDocument('sell gold', 'sell')



    classifier.train()

    testStrings = [
      "send me the income statement for last year"
      "send me the balance sheet for this year"
      "what are last year's sales"
    ]

    testStrings.each (testString)->
      console.log testString
      console.log classifier.classify(testString)






    #console.log nlp.value(parseString).date()

    #console.log parseString
    #instance.init parseString
    #console.log instance.get 'dates'
    #console.log instance.get 'places'
    #console.log instance.get 'relative_time'
}

