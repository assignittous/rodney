var IncomeStatement, Sherlock, aitutils, cson, file, logger;

cson = require("cson");

aitutils = require("aitutils").aitutils;

file = aitutils.file;

logger = aitutils.logger;

require('sugar');

Sherlock = require("../../lib/sherlock");

IncomeStatement = function(knwl) {
  this.languages = {
    'english': true
  };
  this.dictionary = cson.parseCSONFile("config.rodney.dictionary.cson");
  this.calls = function() {
    var matches, sherlocked, text;
    text = knwl.words.get('words').join(" ");
    sherlocked = Sherlock.parse(text);
    if (sherlocked.startDate != null) {
      console.log("---sherlock");
      console.log(JSON.stringify(sherlocked, null, 2));
      if (sherlocked.hasYear != null) {
        console.log(sherlocked.hasYear);
      }
      console.log(Date.create(sherlocked.startDate));
    }
    console.log("income statement rules runnign");
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
    return [
      {
        date: "today"
      }, {
        period: "year"
      }
    ];
  };
};

module.exports = IncomeStatement;
