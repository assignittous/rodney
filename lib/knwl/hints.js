var Hints, aitutils, cson, file, logger;

cson = require("cson");

aitutils = require("aitutils").aitutils;

file = aitutils.file;

logger = aitutils.logger;

Hints = function(knwl) {
  this.languages = {
    'english': true
  };
  this.hints = cson.parseCSONFile("config.rodney.hints.cson");
  console.log("Hints");
  this.calls = function() {
    var matches, text;
    text = knwl.words.get('words').join(" ");
    matches = [];
    this.hints.each(function(parameter) {
      return parameter.synonyms.each(function(synonym) {
        if (text.has(synonym)) {
          return matches.push({
            match: parameter.type,
            matchString: synonym,
            entity: parameter,
            score: synonym.length
          });
        }
      });
    });
    return matches;
  };
};

module.exports = Hints;
