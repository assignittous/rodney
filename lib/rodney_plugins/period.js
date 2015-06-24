
/*

test cases:

-- simple

[this, last, next] year
[this, last, next] quarter
[this, last, next] month
[this, last, next] week
 */
var PeriodFinder, natural, parsePeriod, prefixes, units;

natural = require('natural');

units = ['week', 'month', 'quarter', 'year'];

prefixes = ['this', 'last', 'previous', 'next'];

parsePeriod = function(interval, period) {
  switch (interval) {
    case "year":
      return Date.create(period).endOfYear().format("{yyyy}-{MM}-{dd}");
    case "month":
      return Date.create(period).endOfMonth().format("{yyyy}-{MM}-{dd}");
    case "quarter":
      return 0;
    case "week":
      return Date.create(period).endOfWeek().format("{yyyy}-{MM}-{dd}");
  }
};

PeriodFinder = function(query) {
  var matchIndex, outputObject, prefix, singularTokens, tokenizer, tokens, unitMatches;
  console.log("Looking for period in " + query);
  outputObject = {
    query: query
  };
  tokenizer = new natural.WordTokenizer();
  console.log("tokenize");
  tokens = tokenizer.tokenize(query);
  singularTokens = tokens.map(function(token) {
    return token.singularize();
  });
  unitMatches = singularTokens.intersect(units);
  matchIndex = singularTokens.findIndex(unitMatches.first());
  if (matchIndex > 0) {
    prefix = singularTokens[matchIndex - 1];
    if (prefixes.intersect(prefix).length > 0) {
      outputObject['period'] = [prefix, unitMatches.first()].join(' ');
      outputObject['date'] = parsePeriod(unitMatches.first(), outputObject['period']);
    } else {
      outputObject['period'] = unitMatches.first();
    }
  }
  return console.log(outputObject);
};

module.exports = PeriodFinder;
