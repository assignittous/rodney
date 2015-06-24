var natural, nlp;

nlp = require("nlp_compromise");

natural = require("natural");

require("sugar");

exports.knwl = {
  test: function() {
    var classifier, parseString, testStrings;
    parseString = "sales for Canada and bahamas between last year and this year";
    classifier = new natural.BayesClassifier();
    classifier.addDocument('the qqqq statement', 'report');
    classifier.train();
    testStrings = ["send me the income statement for last year", "send me the balance sheet for this year", "what are last year's sales"];
    return testStrings.each(function(testString) {
      console.log(testString);
      return console.log(classifier.classify(testString));
    });
  }
};
