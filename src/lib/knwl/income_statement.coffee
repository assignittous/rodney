cson = require "cson"
aitutils = require("aitutils").aitutils
file = aitutils.file
logger = aitutils.logger
require 'sugar'
Sherlock = require "../../lib/sherlock"
IncomeStatement = (knwl) ->



  @languages = 'english': true
  @dictionary = cson.parseCSONFile "config.rodney.dictionary.cson"



  checkRelativeDate = (text) ->
    
    return text.match(/((?:next|last|this) (?:week|month|quarter|year)|tom(?:orrow)?|tod(?:ay)?|now|day after tom(?:orrow)?|yesterday|day before yesterday)/gi)
     
  checkYear = (text) ->
    
    return text.match(/\\b(20\\d{2}|\\d{2}[6-9]\\d)\\b/gi)


  @calls = ()->
    matches = []
    text = knwl.words.get('words').join(" ")
    #sherlocked = Sherlock.parse(text)

    # defaults
    period = "year"
    date = Date.create().endOfYear()
    # rules, single date
    #console.log sherlocked
    # get the date 
    #if sherlocked.startDate?
    #  date = Date.create(sherlocked.startDate)

    # # Logic

    # Check for a period - default end of period
    # Check for a period ending date - default today

    ###
    
    Test phrases

    income statement for 2015 >> ytd
    income statement for 2013 >> 12/31/2013
    income statement as at 12/31 >> 12/31/2014
    income statement for last year >> 12/31/2014
    income statement for last month >> 7/31/2015 (year)
    income statement for Q1 2014 >> 3/31/2014 (year)
    income statement for last quarter >> 3/31/2015 (year
)s    income statement for this quarter >> 09/30/2015
    income statement for 08/2013  >> 08/31/2013 (year)


    ###





    patterns = 
      rangeSplitters: /(\bto\b|\-|\b(?:un)?till?\b|\bthrough\b|\bthru\b|\band\b|\bends?\b)/g
      quarter: ''
      months: '\\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\\b'
      days: '\\b(?:(?:(?:on )?the )(?=\\d\\d?(?:st|nd|rd|th)))?([1-2]\\d|3[0-1]|0?[1-9])(?:st|nd|rd|th)?(?:,|\\b)'
      years: '\\b(20\\d{2}|\\d{2}[6-9]\\d)\\b'
      shortForm: /\b(0?[1-9]|1[0-2])\/([1-2]\d|3[0-1]|0?[1-9])\/?(\d{2,4})?\b/
      weekdays: /(?:(next|last) (?:week (?:on )?)?)?\b(sun|mon|tue(?:s)?|wed(?:nes)?|thurs|fri|sat(?:ur)?)(?:day)?\b/
      relativeDateStr: '((?:next|last|this) (?:week|month|quarter|year)|tom(?:orrow)?|tod(?:ay)?|now|day after tom(?:orrow)?|yesterday|day before yesterday)'
      inRelativeDateStr: '(\\d{1,4}|a) (day|week|month|quarter|year)s? ?(ago|old)?'
      inRelativeTime: /\b(\d{1,2} ?|a |an )(h(?:our)?|m(?:in(?:ute)?)?)s? ?(ago|old)?\b/
      inMilliTime: /\b(\d+) ?(s(?:ec(?:ond)?)?|ms|millisecond)s? ?(ago|old)?\b/
      midtime: /(?:@ ?)?\b(?:at )?(noon|midnight)\b/
      internationalTime: /\b(?:(0[0-9]|1[3-9]|2[0-3]):?([0-5]\d))\b/
      explicitTime: /(?:@ ?)?\b(?:at |from )?(1[0-2]|[1-9])(?::?([0-5]\d))? ?([ap]\.?m?\.?)?(?:o'clock)?\b/
      more_than_comparator: /((?:more|greater|newer) than|after)/i
      less_than_comparator: /((?:less|fewer|older) than|before)/i
      fillerWords: RegExp(' (from|is|was|at|on|for|in|due(?! date)|(?:un)?till?)\\b')
      fillerWords2: RegExp(' (was|is|due(?! date))\\b')
      

    console.log "regex========================================="

    re = new RegExp(patterns.relativeDateStr)

    relativeDates = checkRelativeDate(text)

    switch relativeDates.length
      when 0
        logger.info "no relative dates"
      when 1
        logger.info relativeDates[0]
      else
        logger.error "too many relative dates, ambiguous request"
        logger.info relativeDates
    
    console.log "regex========================================="

    #matches.push { date: date }
    #matches.push { period: period }

    # get the period
    ###
    matches = []
    @dictionary.each (entity)->
      synonyms = entity.synonyms.clone().add(entity.name)
      synonyms.each (synonym)->
        if text.has(synonym)
          matches.push {
            match: entity.type
            entity: entity
            score: synonym.length
          }
    ###


    return matches
  return
module.exports = IncomeStatement

