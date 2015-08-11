cson = require "cson"
aitutils = require("aitutils").aitutils
file = aitutils.file
logger = aitutils.logger

SingleDate = (knwl) ->
  @monthToInt=
    'jan': 0
    'feb': 1
    'mar': 2
    'apr': 3
    'may': 4
    'jun': 5
    'jul': 6
    'aug': 7
    'sep': 8
    'oct': 9
    'nov': 10
    'dec': 11
  @wordsToInt=
    'one': 1
    'first': 1
    'two': 2
    'second': 2
    'three': 3
    'third': 3
    'four': 4
    'fourth': 4
    'five': 5
    'fifth': 5
    'six': 6
    'sixth': 6
    'seven': 7
    'seventh': 7
    'eight': 8
    'eighth': 8
    'nine': 9
    'ninth': 9
    'ten': 10
    'tenth': 10
  @intToWords= [
    'one|first'
    'two|second'
    'three|third'
    'four|fourth'
    'five|fifth'
    'six|sixth'
    'seven|seventh'
    'eight|eighth'
    'nine|ninth'
    'ten|tenth'
  ]
  helpers = 
    intToWords: []
  @patterns =
    rangeSplitters: /(\bto\b|\-|\b(?:un)?till?\b|\bthrough\b|\bthru\b|\band\b|\bends?\b)/g
    months: '\\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\\b'
    days: '\\b(?:(?:(?:on )?the )(?=\\d\\d?(?:st|nd|rd|th)))?([1-2]\\d|3[0-1]|0?[1-9])(?:st|nd|rd|th)?(?:,|\\b)'
    years: '\\b(20\\d{2}|\\d{2}[6-9]\\d)\\b'
    shortForm: /\b(0?[1-9]|1[0-2])\/([1-2]\d|3[0-1]|0?[1-9])\/?(\d{2,4})?\b/
    weekdays: /(?:(next|last) (?:week (?:on )?)?)?\b(sun|mon|tue(?:s)?|wed(?:nes)?|thurs|fri|sat(?:ur)?)(?:day)?\b/
    relativeDateStr: '((?:next|last|this) (?:week|month|year)|tom(?:orrow)?|tod(?:ay)?|now|day after tom(?:orrow)?|yesterday|day before yesterday)'
    inRelativeDateStr: '(\\d{1,4}|a) (day|week|month|year)s? ?(ago|old)?'
    inRelativeTime: /\b(\d{1,2} ?|a |an )(h(?:our)?|m(?:in(?:ute)?)?)s? ?(ago|old)?\b/
    inMilliTime: /\b(\d+) ?(s(?:ec(?:ond)?)?|ms|millisecond)s? ?(ago|old)?\b/
    midtime: /(?:@ ?)?\b(?:at )?(noon|midnight)\b/
    internationalTime: /\b(?:(0[0-9]|1[3-9]|2[0-3]):?([0-5]\d))\b/
    explicitTime: /(?:@ ?)?\b(?:at |from )?(1[0-2]|[1-9])(?::?([0-5]\d))? ?([ap]\.?m?\.?)?(?:o'clock)?\b/
    more_than_comparator: /((?:more|greater|newer) than|after)/i
    less_than_comparator: /((?:less|fewer|older) than|before)/i
    fillerWords: RegExp(' (from|is|was|at|on|for|in|due(?! date)|(?:un)?till?)\\b')
    fillerWords2: RegExp(' (was|is|due(?! date))\\b')  
  # may 5, may 5th
  @patterns.monthDay = new RegExp(@patterns.months + ' ' + @patterns.days + '(?: ' + @patterns.years + ')?')
  # 5th may, 5 may
  @patterns.dayMonth = new RegExp(@patterns.days + '(?: (?:day )?of)? ' + @patterns.months + '(?: ' + @patterns.years + ')?')
  # 5, 5th
  @patterns.daysOnly = new RegExp(@patterns.days)
  @patterns.digit = new RegExp('\\b(' + helpers.intToWords.join('|') + ')\\b', 'g')
  # today, tomorrow, day after tomorrow
  @patterns.relativeDate = new RegExp('\\b' + @patterns.relativeDateStr + '\\b')
  # in 2 weeks
  @patterns.inRelativeDate = new RegExp('\\b' + @patterns.inRelativeDateStr + '\\b')
  # 2 weeks from tomorrow
  @patterns.inRelativeDateFromRelativeDate = new RegExp('\\b' + @patterns.inRelativeDateStr + ' from ' + @patterns.relativeDateStr + '\\b')
 
  @languages = 'english': true
  
  
  @calls = ()->
    
    text = knwl.words.get('words').join(" ")

    matches = []


    matches

  return
module.exports = SingleDate

