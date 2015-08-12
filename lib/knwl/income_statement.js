var IncomeStatement, Sherlock, aitutils, cson, file, logger;

cson = require("cson");

aitutils = require("aitutils").aitutils;

file = aitutils.file;

logger = aitutils.logger;

require('sugar');

Sherlock = require("../../lib/sherlock");

IncomeStatement = function(knwl) {
  var checkRelativeDate, checkYear;
  this.languages = {
    'english': true
  };
  this.dictionary = cson.parseCSONFile("config.rodney.dictionary.cson");
  checkRelativeDate = function(text) {
    return text.match(/((?:next|last|this) (?:week|month|quarter|year)|tom(?:orrow)?|tod(?:ay)?|now|day after tom(?:orrow)?|yesterday|day before yesterday)/gi);
  };
  checkYear = function(text) {
    return text.match(/\\b(20\\d{2}|\\d{2}[6-9]\\d)\\b/gi);
  };
  this.calls = function() {
    var date, matches, patterns, period, re, relativeDates, text;
    matches = [];
    text = knwl.words.get('words').join(" ");
    period = "year";
    date = Date.create().endOfYear();
    patterns = {
      rangeSplitters: /(\bto\b|\-|\b(?:un)?till?\b|\bthrough\b|\bthru\b|\band\b|\bends?\b)/g,
      quarter: '',
      months: '\\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\\b',
      days: '\\b(?:(?:(?:on )?the )(?=\\d\\d?(?:st|nd|rd|th)))?([1-2]\\d|3[0-1]|0?[1-9])(?:st|nd|rd|th)?(?:,|\\b)',
      years: '\\b(20\\d{2}|\\d{2}[6-9]\\d)\\b',
      shortForm: /\b(0?[1-9]|1[0-2])\/([1-2]\d|3[0-1]|0?[1-9])\/?(\d{2,4})?\b/,
      weekdays: /(?:(next|last) (?:week (?:on )?)?)?\b(sun|mon|tue(?:s)?|wed(?:nes)?|thurs|fri|sat(?:ur)?)(?:day)?\b/,
      relativeDateStr: '((?:next|last|this) (?:week|month|quarter|year)|tom(?:orrow)?|tod(?:ay)?|now|day after tom(?:orrow)?|yesterday|day before yesterday)',
      inRelativeDateStr: '(\\d{1,4}|a) (day|week|month|quarter|year)s? ?(ago|old)?',
      inRelativeTime: /\b(\d{1,2} ?|a |an )(h(?:our)?|m(?:in(?:ute)?)?)s? ?(ago|old)?\b/,
      inMilliTime: /\b(\d+) ?(s(?:ec(?:ond)?)?|ms|millisecond)s? ?(ago|old)?\b/,
      midtime: /(?:@ ?)?\b(?:at )?(noon|midnight)\b/,
      internationalTime: /\b(?:(0[0-9]|1[3-9]|2[0-3]):?([0-5]\d))\b/,
      explicitTime: /(?:@ ?)?\b(?:at |from )?(1[0-2]|[1-9])(?::?([0-5]\d))? ?([ap]\.?m?\.?)?(?:o'clock)?\b/,
      more_than_comparator: /((?:more|greater|newer) than|after)/i,
      less_than_comparator: /((?:less|fewer|older) than|before)/i,
      fillerWords: RegExp(' (from|is|was|at|on|for|in|due(?! date)|(?:un)?till?)\\b'),
      fillerWords2: RegExp(' (was|is|due(?! date))\\b')
    };
    console.log("regex=========================================");
    re = new RegExp(patterns.relativeDateStr);
    relativeDates = checkRelativeDate(text);
    switch (relativeDates.length) {
      case 0:
        logger.info("no relative dates");
        break;
      case 1:
        logger.info(relativeDates[0]);
        break;
      default:
        logger.error("too many relative dates, ambiguous request");
        logger.info(relativeDates);
    }
    console.log("regex=========================================");

    /*
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
     */
    return matches;
  };
};

module.exports = IncomeStatement;
