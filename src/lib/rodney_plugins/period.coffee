# a period is:

# week, month, quarter, year, fiscal year

###

test cases:

-- simple

[this, last, next] year
[this, last, next] quarter
[this, last, next] month
[this, last, next] week




###

natural = require('natural')

units = ['week','month','quarter', 'year']
prefixes = ['this', 'last', 'previous', 'next']

parsePeriod = (interval, period)->
  switch interval
    when "year"
      return Date.create(period).endOfYear().format("{yyyy}-{MM}-{dd}")
    when "month"
      return Date.create(period).endOfMonth().format("{yyyy}-{MM}-{dd}")
    when "quarter"
      return 0

    when "week"
      return Date.create(period).endOfWeek().format("{yyyy}-{MM}-{dd}")



PeriodFinder = (query)->
  console.log "Looking for period in #{query}"

  outputObject =
    query: query

  tokenizer = new natural.WordTokenizer()
  console.log "tokenize"

  tokens = tokenizer.tokenize(query)

  singularTokens = tokens.map (token)->
    return token.singularize()

  unitMatches = singularTokens.intersect(units)


  matchIndex = singularTokens.findIndex(unitMatches.first())

  if matchIndex > 0
    prefix = singularTokens[matchIndex - 1]
    if prefixes.intersect(prefix).length > 0
      outputObject['period'] = [prefix, unitMatches.first()].join(' ')
      outputObject['date'] = parsePeriod(unitMatches.first(), outputObject['period'])
    else
      outputObject['period'] = unitMatches.first()

  console.log outputObject

module.exports = PeriodFinder
