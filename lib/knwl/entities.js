var Entities, aitutils, cson, file, logger;

cson = require("cson");

aitutils = require("aitutils").aitutils;

file = aitutils.file;

logger = aitutils.logger;

Entities = function(knwl) {
  this.languages = {
    'english': true
  };
  this.dictionary = cson.parseCSONFile("config.rodney.dictionary.cson");
  this.calls = function() {
    var matches, text;
    text = knwl.words.get('words').join(" ");
    matches = [];
    this.dictionary.each(function(entity) {
      var synonyms;
      synonyms = entity.synonyms.clone().add(entity.name);
      return synonyms.each(function(synonym) {
        if (text.has(synonym)) {
          return matches.push({
            match: entity.type,
            entity: entity,
            score: synonym.length
          });
        }
      });
    });
    return matches;
  };
};

module.exports = Entities;
