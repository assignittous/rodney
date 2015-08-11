
/*!
 * Sherlock
 * Copyright (c) 2014 Tabule, Inc.
 * Version 1.3.2
 */

/*

The MIT License (MIT) Copyright (c) 2015 Neil Gupta

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*

Modifications by Steven Ng
 */
var Sherlock;

require("sugar");

Sherlock = (function() {
  var getNow, helpers, makeAdjustments, matchDate, matchTime, nowDate, parser, patterns, readConfig;
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
  nowDate = null;
  getNow = function() {
    if (nowDate) {
      return new Date(nowDate.getTime());
    } else {
      return new Date;
    }
  };
  readConfig = function(config_var) {
    if (typeof Watson !== 'undefined' && Watson.config) {
      return Watson.config[config_var];
    } else {
      return null;
    }
  };
  parser = function(str, time, startTime) {
    var dateMatch, ret, strNummed, timeMatch;
    ret = {};
    dateMatch = false;
    timeMatch = false;
    strNummed = helpers.strToNum(str);
    if (dateMatch = matchDate(strNummed, time, startTime)) {
      strNummed = strNummed.replace(new RegExp(dateMatch), '');
      str = str.replace(new RegExp(helpers.numToStr(dateMatch)), '');
    }
    if (timeMatch = matchTime(strNummed, time, startTime)) {
      str = str.replace(new RegExp(helpers.numToStr(timeMatch)), '');
    }
    ret.eventTitle = str;
    ret.isAllDay = !!(dateMatch && !timeMatch && dateMatch !== 'now');
    ret.isValidDate = !!(dateMatch || timeMatch);
    return ret;
  };
  matchTime = function(str, time, startTime) {
    var hour, match, matchConfidence, matchedHasMeridian, matchedHour, matchedMin, matchedString, meridian, min, useLowConfidenceMatchedTime;
    match = void 0;
    matchConfidence = 0;
    matchedString = false;
    matchedHour = void 0;
    matchedMin = void 0;
    matchedHasMeridian = void 0;
    if (match = str.match(new RegExp(patterns.explicitTime.source, 'g'))) {
      match = match.sort(function(a, b) {
        var aScore, bScore;
        aScore = a.trim().length;
        bScore = b.trim().length;
        if (a.match(/(?:a|p).?m.?/)) {
          aScore += 20;
        }
        if (b.match(/(?:a|p).?m.?/)) {
          bScore += 20;
        }
        return bScore - aScore;
      })[0].trim();
      if (match.length <= 2 && str.trim().length > 2) {
        matchConfidence = 0;
      } else {
        matchConfidence = match.length;
        match = match.match(patterns.explicitTime);
        hour = parseInt(match[1]);
        min = match[2] || 0;
        meridian = match[3];
        if (meridian) {
          if (meridian.indexOf('p') === 0 && hour !== 12) {
            hour += 12;
          } else if (meridian.indexOf('a') === 0 && hour === 12) {
            hour = 0;
          }
          matchConfidence += 20;
        } else if (hour < 12 && (hour < 7 || hour < time.getHours())) {
          hour += 12;
        }
        matchedHour = hour;
        matchedMin = min;
        matchedHasMeridian = !!meridian;
        matchedString = match[0];
      }
    }
    useLowConfidenceMatchedTime = function() {
      if (matchedString) {
        time.setHours(matchedHour, matchedMin, 0);
        time.hasMeridian = matchedHasMeridian;
      }
      return matchedString;
    };
    if (matchConfidence < 4) {
      if (match = str.match(patterns.inRelativeTime)) {
        if (isNaN(match[1])) {
          match[1] = 1;
        }
        if (match[3]) {
          match[1] = parseInt(match[1]) * -1;
        }
        switch (match[2].substring(0, 1)) {
          case 'h':
            time.setHours(time.getHours() + parseInt(match[1]));
            return match[0];
          case 'm':
            time.setMinutes(time.getMinutes() + parseInt(match[1]));
            return match[0];
          default:
            return useLowConfidenceMatchedTime();
        }
      } else if (match = str.match(patterns.inMilliTime)) {
        if (match[3]) {
          match[1] = parseInt(match[1]) * -1;
        }
        switch (match[2].substring(0, 1)) {
          case 's':
            time.setSeconds(time.getSeconds() + parseInt(match[1]));
            return match[0];
          case 'm':
            time.setMilliseconds(time.getMilliseconds() + parseInt(match[1]));
            return match[0];
          default:
            return useLowConfidenceMatchedTime();
        }
      } else if (match = str.match(patterns.midtime)) {
        switch (match[1]) {
          case 'noon':
            time.setHours(12, 0, 0);
            time.hasMeridian = true;
            return match[0];
          case 'midnight':
            time.setHours(0, 0, 0);
            time.hasMeridian = true;
            return match[0];
          default:
            return useLowConfidenceMatchedTime();
        }
      } else if (match = str.match(patterns.internationalTime)) {
        time.setHours(match[1], match[2], 0);
        time.hasMeridian = true;
        return match[0];
      } else {
        return useLowConfidenceMatchedTime();
      }
    } else {
      return useLowConfidenceMatchedTime();
    }
  };
  matchDate = function(str, time, startTime) {
    var day, match, month, year, yearStr;
    match = void 0;
    if (match = str.match(patterns.monthDay)) {
      if (match[3]) {
        time.setFullYear(match[3], helpers.changeMonth(match[1]), match[2]);
        time.hasYear = true;
      } else {
        time.setMonth(helpers.changeMonth(match[1]), match[2]);
      }
      return match[0];
    } else if (match = str.match(patterns.dayMonth)) {
      if (match[3]) {
        time.setFullYear(match[3], helpers.changeMonth(match[2]), match[1]);
        time.hasYear = true;
      } else {
        time.setMonth(helpers.changeMonth(match[2]), match[1]);
      }
      return match[0];
    } else if (match = str.match(patterns.shortForm)) {
      yearStr = match[3];
      year = null;
      if (yearStr) {
        year = parseInt(yearStr);
      }
      if (year && yearStr.length < 4) {
        year += year > 50 ? 1900 : 2000;
      }
      if (year) {
        time.setFullYear(year, match[1] - 1, match[2]);
        time.hasYear = true;
      } else {
        time.setMonth(match[1] - 1, match[2]);
      }
      return match[0];
    } else if (match = str.match(patterns.weekdays)) {
      switch (match[2].substr(0, 3)) {
        case 'sun':
          helpers.changeDay(time, 0, match[1]);
          return match[0];
        case 'mon':
          helpers.changeDay(time, 1, match[1]);
          return match[0];
        case 'tue':
          helpers.changeDay(time, 2, match[1]);
          return match[0];
        case 'wed':
          helpers.changeDay(time, 3, match[1]);
          return match[0];
        case 'thu':
          helpers.changeDay(time, 4, match[1]);
          return match[0];
        case 'fri':
          helpers.changeDay(time, 5, match[1]);
          return match[0];
        case 'sat':
          helpers.changeDay(time, 6, match[1]);
          return match[0];
        default:
          return false;
      }
    } else if (match = str.match(patterns.inRelativeDateFromRelativeDate)) {
      if (helpers.relativeDateMatcher(match[4], time) && helpers.inRelativeDateMatcher(match[1], match[2], match[3], time)) {
        return match[0];
      } else {
        return false;
      }
    } else if (match = str.match(patterns.relativeDate)) {
      if (helpers.relativeDateMatcher(match[1], time)) {
        return match[0];
      } else {
        return false;
      }
    } else if (match = str.match(patterns.inRelativeDate)) {
      if (helpers.inRelativeDateMatcher(match[1], match[2], match[3], time)) {
        return match[0];
      } else {
        return false;
      }
    } else if (match = str.match(new RegExp(patterns.days, 'g'))) {
      match = match.sort(function(a, b) {
        return b.trim().length - (a.trim().length);
      })[0].trim();
      if (match.indexOf('on') !== 0 && !(match.indexOf('the') === 0 && match.indexOf(',', match.length - 1) !== -1) && str.indexOf(match, str.length - match.length - 1) === -1 || !(startTime && startTime.isAllDay) && match.length <= 2) {
        return false;
      }
      match = match.match(patterns.daysOnly);
      month = time.getMonth();
      day = match[1];
      if (day < time.getDate()) {
        month++;
      }
      time.setMonth(month, day);
      return match[0];
    } else {
      return false;
    }
  };
  makeAdjustments = function(start, end, isAllDay, str, ret) {
    var now;
    now = getNow();
    if (end) {
      if (start > end && end > now && helpers.isSameDay(start, end) && helpers.isSameDay(start, now)) {
        if (start.hasMeridian) {
          start.setDate(start.getDate() - 1);
        } else {
          start.setHours(start.getHours() - 12);
          if (start > end) {
            start.setHours(start.getHours() - 12);
          }
        }
      } else if (start > end) {
        end.setDate(start.getDate() + 1);
      } else if (end < now && str.indexOf(' was ') === -1 && helpers.monthDiff(end, now) >= 3 && !end.hasYear && !start.hasYear) {
        end.setFullYear(end.getFullYear() + 1);
        start.setFullYear(start.getFullYear() + 1);
      }
    } else if (start) {
      if (start < now && helpers.monthDiff(start, now) >= 3 && !start.hasYear && str.indexOf(' was ') === -1) {
        start.setFullYear(start.getFullYear() + 1);
      } else if (ret.eventTitle.match(patterns.more_than_comparator)) {
        if (str.match(/(ago|old)/i) && ret.eventTitle.match(/(ago|old)/i) === null) {
          ret.endDate = new Date(start.getTime());
          ret.startDate = new Date(1900, 0, 1, 0, 0, 0, 0);
        } else {
          ret.endDate = new Date(3000, 0, 1, 0, 0, 0, 0);
        }
        ret.eventTitle = ret.eventTitle.replace(patterns.more_than_comparator, '');
      } else if (ret.eventTitle.match(patterns.less_than_comparator)) {
        if (str.match(/(ago|old)/i) && ret.eventTitle.match(/(ago|old)/i) === null) {
          ret.endDate = new Date(3000, 0, 1, 0, 0, 0, 0);
        } else {
          ret.endDate = new Date(start.getTime());
          ret.startDate = new Date(1900, 0, 1, 0, 0, 0, 0);
        }
        ret.eventTitle = ret.eventTitle.replace(patterns.less_than_comparator, '');
      }
    }
  };
  helpers = {
    relativeDateMatcher: function(match, time) {
      var now;
      now = getNow();
      switch (match) {
        case 'next week':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate() + 7);
          return true;
        case 'next month':
          time.setFullYear(now.getFullYear(), now.getMonth() + 1, now.getDate());
          return true;
        case 'next year':
          time.setFullYear(now.getFullYear() + 1, 11, 31);
          return true;
        case 'last week':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate() - 7);
          return true;
        case 'last month':
          time.setFullYear(now.getFullYear(), now.getMonth() - 1, now.getDate());
          return true;
        case 'last year':
          time.setFullYear(now.getFullYear() - 1, 11, 31);
          return true;
        case 'this week':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate());
          return true;
        case 'this month':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate());
          return true;
        case 'this year':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate());
          return true;
        case 'tom':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate() + 1);
          return true;
        case 'tomorrow':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate() + 1);
          return true;
        case 'day after tomorrow':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate() + 2);
          return true;
        case 'day after tom':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate() + 2);
          return true;
        case 'today':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate());
          return true;
        case 'tod':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate());
          return true;
        case 'now':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate());
          time.setHours(now.getHours(), now.getMinutes(), now.getSeconds(), 0);
          time.hasMeridian = true;
          return true;
        case 'yesterday':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate() - 1);
          return true;
        case 'day before yesterday':
          time.setFullYear(now.getFullYear(), now.getMonth(), now.getDate() - 2);
          return true;
        default:
          return false;
      }
    },
    inRelativeDateMatcher: function(num, scale, ago, time) {
      if (isNaN(num)) {
        num = 1;
      } else {
        num = parseInt(num);
      }
      if (ago) {
        num = num * -1;
      }
      switch (scale) {
        case 'day':
          time.setDate(time.getDate() + num);
          time.hasYear = true;
          return true;
        case 'week':
          time.setDate(time.getDate() + num * 7);
          time.hasYear = true;
          return true;
        case 'month':
          time.setMonth(time.getMonth() + num);
          time.hasYear = true;
          return true;
        case 'year':
          time.setFullYear(time.getFullYear() + num);
          time.hasYear = true;
          return true;
        default:
          return false;
      }
    },
    changeMonth: function(month) {
      return this.monthToInt[month.substr(0, 3)];
    },
    changeDay: function(time, newDay, hasNext) {
      var diff;
      diff = 7 - time.getDay() + newDay;
      if (diff > 7 && hasNext === void 0) {
        diff -= 7;
      }
      if (hasNext === 'last') {
        diff = diff * -1;
      }
      time.setDate(time.getDate() + diff);
    },
    monthDiff: function(d1, d2) {
      var months;
      months = void 0;
      months = (d2.getFullYear() - d1.getFullYear()) * 12;
      months -= d1.getMonth() + 1;
      months += d2.getMonth() + 1;
      if (months <= 0) {
        return 0;
      } else {
        return months;
      }
    },
    escapeRegExp: function(str) {
      return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');
    },
    isSameDay: function(date1, date2) {
      return date1.getMonth() === date2.getMonth() && date1.getDate() === date2.getDate() && date1.getFullYear() === date2.getFullYear();
    },
    monthToInt: {
      'jan': 0,
      'feb': 1,
      'mar': 2,
      'apr': 3,
      'may': 4,
      'jun': 5,
      'jul': 6,
      'aug': 7,
      'sep': 8,
      'oct': 9,
      'nov': 10,
      'dec': 11
    },
    wordsToInt: {
      'one': 1,
      'first': 1,
      'two': 2,
      'second': 2,
      'three': 3,
      'third': 3,
      'four': 4,
      'fourth': 4,
      'five': 5,
      'fifth': 5,
      'six': 6,
      'sixth': 6,
      'seven': 7,
      'seventh': 7,
      'eight': 8,
      'eighth': 8,
      'nine': 9,
      'ninth': 9,
      'ten': 10,
      'tenth': 10
    },
    intToWords: ['one|first', 'two|second', 'three|third', 'four|fourth', 'five|fifth', 'six|sixth', 'seven|seventh', 'eight|eighth', 'nine|ninth', 'ten|tenth'],
    strToNum: function(str) {
      return str.replace(patterns.digit, function(val) {
        var out;
        out = helpers.wordsToInt[val];
        if (val.indexOf('th', val.length - 2) !== -1) {
          out += 'th';
        } else if (val.indexOf('st', val.length - 2) !== -1) {
          out += 'st';
        } else if (val.indexOf('nd', val.length - 2) !== -1) {
          out += 'nd';
        } else if (val.indexOf('rd', val.length - 2) !== -1) {
          out += 'rd';
        }
        return out;
      });
    },
    numToStr: function(str) {
      return str.replace(/((?:[1-9]|10)(?:st|nd|rd|th)?)/g, function(val) {
        return '(?:' + val + '|' + helpers.intToWords[parseInt(val) - 1] + ')';
      });
    }
  };
  patterns.monthDay = new RegExp(patterns.months + ' ' + patterns.days + '(?: ' + patterns.years + ')?');
  patterns.dayMonth = new RegExp(patterns.days + '(?: (?:day )?of)? ' + patterns.months + '(?: ' + patterns.years + ')?');
  patterns.daysOnly = new RegExp(patterns.days);
  patterns.digit = new RegExp('\\b(' + helpers.intToWords.join('|') + ')\\b', 'g');
  patterns.relativeDate = new RegExp('\\b' + patterns.relativeDateStr + '\\b');
  patterns.inRelativeDate = new RegExp('\\b' + patterns.inRelativeDateStr + '\\b');
  patterns.inRelativeDateFromRelativeDate = new RegExp('\\b' + patterns.inRelativeDateStr + ' from ' + patterns.relativeDateStr + '\\b');
  if (!String.prototype.trim) {
    String.prototype.trim = function() {
      return this.replace(/^\s+|\s+$/g, '');
    };
  }
  return {
    parse: function(str) {
      var k;
      var tokensTmp;
      var str;
      var date, fillerWords, k, match, result, ret, tokens, tokensTmp;
      if (str === null) {
        str = '';
      }
      date = getNow();
      result = typeof Watson !== 'undefined' ? Watson.preprocess(str) : [str, {}];
      str = result[0];
      ret = result[1];
      tokens = readConfig('disableRanges') ? [str.toLowerCase()] : str.toLowerCase().split(patterns.rangeSplitters);
      patterns.rangeSplitters.lastIndex = 0;
      date.setMilliseconds(0);
      while (!ret.startDate) {
        if ((result = parser(tokens[0], date, null)) !== null) {
          if (result.isAllDay) {
            date.setHours(0, 0, 0);
          }
          ret.isAllDay = result.isAllDay;
          ret.eventTitle = result.eventTitle;
          ret.startDate = result.isValidDate ? date : null;
        }
        if (!ret.startDate && tokens.length >= 3) {
          tokensTmp = [tokens[0] + tokens[1] + tokens[2]];
          k = 3;
          while (k < tokens.length) {
            tokensTmp.push(tokens[k]);
            k++;
          }
          tokens = tokensTmp;
        } else {
          break;
        }
      }
      while (!ret.endDate) {
        if (tokens.length > 1) {
          date = new Date(date.getTime());
          if ((result = parser(tokens[2], date, ret)) !== null) {
            if (ret.isAllDay) {
              date.setHours(0, 0, 0);
            }
            if (result.eventTitle.length > ret.eventTitle.length) {
              ret.eventTitle = result.eventTitle;
            }
            ret.endDate = result.isValidDate ? date : null;
          }
        }
        if (!ret.endDate) {
          if (tokens.length >= 4) {
            tokensTmp = [tokens[0], tokens[1], tokens[2] + tokens[3] + tokens[4]];
            k = 5;
            while (k < tokens.length) {
              tokensTmp.push(tokens[k]);
              k++;
            }
            tokens = tokensTmp;
          } else {
            ret.endDate = null;
            break;
          }
        }
      }
      makeAdjustments(ret.startDate, ret.endDate, ret.isAllDay, str, ret);
      if (ret.eventTitle) {
        fillerWords = readConfig('disableRanges') ? patterns.fillerWords2 : patterns.fillerWords;
        ret.eventTitle = ret.eventTitle.split(fillerWords)[0].trim();
        ret.eventTitle = ret.eventTitle.replace(/(?:^| )(?:\.|-$|by$|in$|at$|from$|on$|starts?$|for$|(?:un)?till?$|!|,|;)+/g, '').replace(RegExp(' +', 'g'), ' ').trim();
        match = str.match(new RegExp(helpers.escapeRegExp(ret.eventTitle), 'i'));
        if (match) {
          ret.eventTitle = match[0].replace(RegExp(' +', 'g'), ' ').trim();
          if (ret.eventTitle === '') {
            ret.eventTitle = null;
          }
        }
      } else {
        ret.eventTitle = null;
      }
      if (typeof Watson !== 'undefined') {
        Watson.postprocess(ret);
      }
      return ret;
    },
    _setNow: function(newDate) {
      nowDate = newDate;
    }
  };
})();

if (typeof define === 'function' && define.amd) {
  define(Sherlock);
} else if (typeof module !== 'undefined' && module.exports) {
  module.exports = Sherlock;
}
