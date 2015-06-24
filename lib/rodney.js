var config, natural, nlp, periodFinder, speak;

require('sugar');

config = require('../lib/configuration').Configuration;

periodFinder = require('../lib/rodney_plugins/period');

natural = require('natural');

nlp = require("nlp_compromise");

speak = require("speakeasy-nlp");

exports.Rodney = {
  findEntities: function(query) {
    var dictionary, matches;
    matches = [];
    dictionary = Object.keys(config.dictionary).sortBy('length', true);
    return dictionary.each(function(item) {
      if (query.has(item)) {
        return matches.push(item);
      }
    });
  },
  parse: function(query) {
    console.log("rodney says hi");
    console.log("you asked " + query);
    console.log(speak.classify(query));
    return console.log("=============================");

    /*
    sentences = nlp.sentences(query)
    console.log "#{sentences.length} sentences detected."
    nlp.pos(query).sentences.each (sentence)->
      console.log "sentence: "
      console.log sentence.text()
      console.log "tags"
      console.log sentence.tags()
      console.log "entities"
      console.log nlp.pos(query)
     */
  }
};
