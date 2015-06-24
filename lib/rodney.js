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
    var classification, intent, output;
    output = {};
    console.log("=============================");
    console.log("=============================");
    console.log(query);
    console.log("=============================");
    classification = speak.classify(query);
    console.log("-----------------------------");
    intent = "";
    switch (classification.action) {
      case "what":
      case "how":
        intent = "metric";
        break;
      default:
        intent = "other";
    }
    console.log("-----------------------------");
    console.log("intent: " + intent);
    console.log(classification.nouns);
    console.log("-----------------------------");
    console.log(classification);
    console.log("=============================");
    output = {
      query: query,
      owner: classification.owner || "",
      guessed_entity: classification.subject || "",
      entity_type: intent
    };

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
    return output;
  }
};
