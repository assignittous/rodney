var RelativeTime, nlp;

require('sugar');

nlp = require("nlp_compromise");

RelativeTime = function(knwlInstance) {
  this.languages = {
    english: true
  };
  this.calls = function() {
    var common_relative_modifiers, common_relative_periods, matches, results, resultsArray, words;
    words = knwlInstance.words.get('words');
    resultsArray = [];
    common_relative_modifiers = ["next", "last", "past"];
    common_relative_periods = ["yesterday", "today", "week", "month", "quarter", "half", "year"];
    matches = common_relative_periods.intersect(words);
    console.log(knwlInstance);

    /*
    
    Parser Code
     */
    results = words;
    return results;
  };
};

module.exports = RelativeTime;
