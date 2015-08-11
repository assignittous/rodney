###!
# Sherlock
# Copyright (c) 2014 Tabule, Inc.
# Version 1.3.2
###
###

The MIT License (MIT) Copyright (c) 2015 Neil Gupta

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

###
###

Modifications by Steven Ng

###
require "sugar"
Sherlock = do ->
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
  nowDate = null

  getNow = ->
    if nowDate
      new Date(nowDate.getTime())
    else
      new Date

  readConfig = (config_var) ->
    if typeof Watson != 'undefined' and Watson.config then Watson.config[config_var] else null

  parser = (str, time, startTime) ->
    ret = {}
    dateMatch = false
    timeMatch = false
    strNummed = helpers.strToNum(str)
    # parse date
    if dateMatch = matchDate(strNummed, time, startTime)
      strNummed = strNummed.replace(new RegExp(dateMatch), '')
      str = str.replace(new RegExp(helpers.numToStr(dateMatch)), '')
    # parse time
    if timeMatch = matchTime(strNummed, time, startTime)
      str = str.replace(new RegExp(helpers.numToStr(timeMatch)), '')
    ret.eventTitle = str
    # if time data not given, then this is an all day event
    ret.isAllDay = ! !(dateMatch and !timeMatch and dateMatch != 'now')
    # check if date was parsed
    ret.isValidDate = ! !(dateMatch or timeMatch)
    ret

  matchTime = (str, time, startTime) ->
    match = undefined
    matchConfidence = 0
    matchedString = false
    matchedHour = undefined
    matchedMin = undefined
    matchedHasMeridian = undefined
    if match = str.match(new RegExp(patterns.explicitTime.source, 'g'))
      # if multiple matches found, pick the best one
      match = match.sort((a, b) ->
        aScore = a.trim().length
        bScore = b.trim().length
        # Weight matches that include full meridian
        if a.match(/(?:a|p).?m.?/)
          aScore += 20
        if b.match(/(?:a|p).?m.?/)
          bScore += 20
        bScore - aScore
      )[0].trim()
      if match.length <= 2 and str.trim().length > 2
        matchConfidence = 0
      else
        matchConfidence = match.length
        match = match.match(patterns.explicitTime)
        hour = parseInt(match[1])
        min = match[2] or 0
        meridian = match[3]
        if meridian
          # meridian is included, adjust hours accordingly
          if meridian.indexOf('p') == 0 and hour != 12
            hour += 12
          else if meridian.indexOf('a') == 0 and hour == 12
            hour = 0
          matchConfidence += 20
        else if hour < 12 and (hour < 7 or hour < time.getHours())
          hour += 12
        matchedHour = hour
        matchedMin = min
        matchedHasMeridian = ! !meridian
        matchedString = match[0]

    useLowConfidenceMatchedTime = ->
      if matchedString
        time.setHours matchedHour, matchedMin, 0
        time.hasMeridian = matchedHasMeridian
      matchedString

    if matchConfidence < 4
      if match = str.match(patterns.inRelativeTime)
        # if we matched 'a' or 'an', set the number to 1
        if isNaN(match[1])
          match[1] = 1
        if match[3]
          match[1] = parseInt(match[1]) * -1
        switch match[2].substring(0, 1)
          when 'h'
            time.setHours time.getHours() + parseInt(match[1])
            return match[0]
          when 'm'
            time.setMinutes time.getMinutes() + parseInt(match[1])
            return match[0]
          else
            return useLowConfidenceMatchedTime()
      else if match = str.match(patterns.inMilliTime)
        if match[3]
          match[1] = parseInt(match[1]) * -1
        switch match[2].substring(0, 1)
          when 's'
            time.setSeconds time.getSeconds() + parseInt(match[1])
            return match[0]
          when 'm'
            time.setMilliseconds time.getMilliseconds() + parseInt(match[1])
            return match[0]
          else
            return useLowConfidenceMatchedTime()
      else if match = str.match(patterns.midtime)
        switch match[1]
          when 'noon'
            time.setHours 12, 0, 0
            time.hasMeridian = true
            return match[0]
          when 'midnight'
            time.setHours 0, 0, 0
            time.hasMeridian = true
            return match[0]
          else
            return useLowConfidenceMatchedTime()
      else if match = str.match(patterns.internationalTime)
        time.setHours match[1], match[2], 0
        time.hasMeridian = true
        return match[0]
      else
        return useLowConfidenceMatchedTime()
    else
      return useLowConfidenceMatchedTime()
    return

  matchDate = (str, time, startTime) ->
    match = undefined
    if match = str.match(patterns.monthDay)
      if match[3]
        time.setFullYear match[3], helpers.changeMonth(match[1]), match[2]
        time.hasYear = true
      else
        time.setMonth helpers.changeMonth(match[1]), match[2]
      return match[0]
    else if match = str.match(patterns.dayMonth)
      if match[3]
        time.setFullYear match[3], helpers.changeMonth(match[2]), match[1]
        time.hasYear = true
      else
        time.setMonth helpers.changeMonth(match[2]), match[1]
      return match[0]
    else if match = str.match(patterns.shortForm)
      yearStr = match[3]
      year = null
      if yearStr
        year = parseInt(yearStr)
      if year and yearStr.length < 4
        year += if year > 50 then 1900 else 2000
      if year
        time.setFullYear year, match[1] - 1, match[2]
        time.hasYear = true
      else
        time.setMonth match[1] - 1, match[2]
      return match[0]
    else if match = str.match(patterns.weekdays)
      switch match[2].substr(0, 3)
        when 'sun'
          helpers.changeDay time, 0, match[1]
          return match[0]
        when 'mon'
          helpers.changeDay time, 1, match[1]
          return match[0]
        when 'tue'
          helpers.changeDay time, 2, match[1]
          return match[0]
        when 'wed'
          helpers.changeDay time, 3, match[1]
          return match[0]
        when 'thu'
          helpers.changeDay time, 4, match[1]
          return match[0]
        when 'fri'
          helpers.changeDay time, 5, match[1]
          return match[0]
        when 'sat'
          helpers.changeDay time, 6, match[1]
          return match[0]
        else
          return false
    else if match = str.match(patterns.inRelativeDateFromRelativeDate)
      if helpers.relativeDateMatcher(match[4], time) and helpers.inRelativeDateMatcher(match[1], match[2], match[3], time)
        return match[0]
      else
        return false
    else if match = str.match(patterns.relativeDate)
      if helpers.relativeDateMatcher(match[1], time)
        return match[0]
      else
        return false
    else if match = str.match(patterns.inRelativeDate)
      if helpers.inRelativeDateMatcher(match[1], match[2], match[3], time)
        return match[0]
      else
        return false
    else if match = str.match(new RegExp(patterns.days, 'g'))
      # if multiple matches found, pick the best one
      match = match.sort((a, b) ->
        b.trim().length - (a.trim().length)
      )[0].trim()
      # check if the possible date match meets our reasonable assumptions...
      # if the match doesn't start with 'on',
      if match.indexOf('on') != 0 and !(match.indexOf('the') == 0 and match.indexOf(',', match.length - 1) != -1) and str.indexOf(match, str.length - (match.length) - 1) == -1 or !(startTime and startTime.isAllDay) and match.length <= 2
        return false
      match = match.match(patterns.daysOnly)
      month = time.getMonth()
      day = match[1]
      # if this date is in the past, move it to next month
      if day < time.getDate()
        month++
      time.setMonth month, day
      return match[0]
    else
      return false
    return

  makeAdjustments = (start, end, isAllDay, str, ret) ->
    now = getNow()
    if end
      if start > end and end > now and helpers.isSameDay(start, end) and helpers.isSameDay(start, now)
        if start.hasMeridian
          start.setDate start.getDate() - 1
        else
          # we are dealing with a time range that is today with start > end 
          # (ie. 9pm - 5pm when we want 9am - 5pm), roll back 12 hours.
          start.setHours start.getHours() - 12
          # if start is still higher than end, that means we probably have
          # 9am - 5am, so roll back another 12 hours to get 9pm yesterday - 5am today
          if start > end
            start.setHours start.getHours() - 12
      else if start > end
        end.setDate start.getDate() + 1
      else if end < now and str.indexOf(' was ') == -1 and helpers.monthDiff(end, now) >= 3 and !end.hasYear and !start.hasYear
        end.setFullYear end.getFullYear() + 1
        start.setFullYear start.getFullYear() + 1
    else if start
      if start < now and helpers.monthDiff(start, now) >= 3 and !start.hasYear and str.indexOf(' was ') == -1
        start.setFullYear start.getFullYear() + 1
      else if ret.eventTitle.match(patterns.more_than_comparator)
        # if "ago" is used and matched (not showing in title), then we need to invert the more than comparator
        if str.match(/(ago|old)/i) and ret.eventTitle.match(/(ago|old)/i) == null
          ret.endDate = new Date(start.getTime())
          ret.startDate = new Date(1900, 0, 1, 0, 0, 0, 0)
        else
          ret.endDate = new Date(3000, 0, 1, 0, 0, 0, 0)
        ret.eventTitle = ret.eventTitle.replace(patterns.more_than_comparator, '')
      else if ret.eventTitle.match(patterns.less_than_comparator)
        # if "ago" is used and matched (not showing in title), then we need to invert the less than comparator
        if str.match(/(ago|old)/i) and ret.eventTitle.match(/(ago|old)/i) == null
          ret.endDate = new Date(3000, 0, 1, 0, 0, 0, 0)
        else
          ret.endDate = new Date(start.getTime())
          ret.startDate = new Date(1900, 0, 1, 0, 0, 0, 0)
        ret.eventTitle = ret.eventTitle.replace(patterns.less_than_comparator, '')
    return

  helpers = 
    relativeDateMatcher: (match, time) ->
      now = getNow()
      switch match
        when 'next week'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate() + 7
          
          return true
        when 'next month'
          time.setFullYear now.getFullYear(), now.getMonth() + 1, now.getDate()
          
          return true
        when 'next year'
          time.setFullYear now.getFullYear() + 1, 11, 31
          
          return true
        when 'last week'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate() - 7
          
          return true
        when 'last month'
          time.setFullYear now.getFullYear(), now.getMonth() - 1, now.getDate()
          
          return true
        when 'last year'
          time.setFullYear now.getFullYear() - 1, 11, 31
          
          return true
        when 'this week'
          # this week|month|year is pretty meaningless, but let's include it so that it parses as today
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate()
          
          return true
        when 'this month'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate()
          
          return true
        when 'this year'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate()
          
          return true
        when 'tom'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate() + 1
          
          return true
        when 'tomorrow'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate() + 1
          
          return true
        when 'day after tomorrow'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate() + 2
          
          return true
        when 'day after tom'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate() + 2
          
          return true
        when 'today'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate()
          
          return true
        when 'tod'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate()
          
          return true
        when 'now'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate()
          time.setHours now.getHours(), now.getMinutes(), now.getSeconds(), 0
          time.hasMeridian = true
          
          return true
        when 'yesterday'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate() - 1
          
          return true
        when 'day before yesterday'
          time.setFullYear now.getFullYear(), now.getMonth(), now.getDate() - 2
          
          return true
        else
          return false
      return
    inRelativeDateMatcher: (num, scale, ago, time) ->
      # if we matched 'a' or 'an', set the number to 1
      if isNaN(num)
        num = 1
      else
        num = parseInt(num)
      if ago
        num = num * -1
      switch scale
        when 'day'
          time.setDate time.getDate() + num
          time.hasYear = true
          return true
        when 'week'
          time.setDate time.getDate() + num * 7
          time.hasYear = true
          return true
        when 'month'
          time.setMonth time.getMonth() + num
          time.hasYear = true
          return true
        when 'year'
          time.setFullYear time.getFullYear() + num
          time.hasYear = true
          return true
        else
          return false
      return
    changeMonth: (month) ->
      @monthToInt[month.substr(0, 3)]
    changeDay: (time, newDay, hasNext) ->
      diff = 7 - time.getDay() + newDay
      if diff > 7 and hasNext == undefined
        diff -= 7
      if hasNext == 'last'
        diff = diff * -1
      time.setDate time.getDate() + diff
      return
    monthDiff: (d1, d2) ->
      months = undefined
      months = (d2.getFullYear() - d1.getFullYear()) * 12
      months -= d1.getMonth() + 1
      months += d2.getMonth() + 1
      if months <= 0 then 0 else months
    escapeRegExp: (str) ->
      str.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&'
    isSameDay: (date1, date2) ->
      date1.getMonth() == date2.getMonth() and date1.getDate() == date2.getDate() and date1.getFullYear() == date2.getFullYear()
    monthToInt:
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
    wordsToInt:
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
    intToWords: [
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
    strToNum: (str) ->
      str.replace patterns.digit, (val) ->
        out = helpers.wordsToInt[val]
        if val.indexOf('th', val.length - 2) != -1
          out += 'th'
        else if val.indexOf('st', val.length - 2) != -1
          out += 'st'
        else if val.indexOf('nd', val.length - 2) != -1
          out += 'nd'
        else if val.indexOf('rd', val.length - 2) != -1
          out += 'rd'
        out
    numToStr: (str) ->
      str.replace /((?:[1-9]|10)(?:st|nd|rd|th)?)/g, (val) ->
        '(?:' + val + '|' + helpers.intToWords[parseInt(val) - 1] + ')'
  # may 5, may 5th
  patterns.monthDay = new RegExp(patterns.months + ' ' + patterns.days + '(?: ' + patterns.years + ')?')
  # 5th may, 5 may
  patterns.dayMonth = new RegExp(patterns.days + '(?: (?:day )?of)? ' + patterns.months + '(?: ' + patterns.years + ')?')
  # 5, 5th
  patterns.daysOnly = new RegExp(patterns.days)
  patterns.digit = new RegExp('\\b(' + helpers.intToWords.join('|') + ')\\b', 'g')
  # today, tomorrow, day after tomorrow
  patterns.relativeDate = new RegExp('\\b' + patterns.relativeDateStr + '\\b')
  # in 2 weeks
  patterns.inRelativeDate = new RegExp('\\b' + patterns.inRelativeDateStr + '\\b')
  # 2 weeks from tomorrow
  patterns.inRelativeDateFromRelativeDate = new RegExp('\\b' + patterns.inRelativeDateStr + ' from ' + patterns.relativeDateStr + '\\b')
  if !String::trim

    String::trim = ->
      @replace /^\s+|\s+$/g, ''

  {
    parse: (str) ->
      `var k`
      `var tokensTmp`
      `var str`
      # check for null input
      if str == null
        str = ''
      date = getNow()
      result = if typeof Watson != 'undefined' then Watson.preprocess(str) else [
        str
        {}
      ]
      str = result[0]
      ret = result[1]
      tokens = if readConfig('disableRanges') then [ str.toLowerCase() ] else str.toLowerCase().split(patterns.rangeSplitters)
      patterns.rangeSplitters.lastIndex = 0
      # normalize all dates to 0 milliseconds
      date.setMilliseconds 0
      while !ret.startDate
        # parse the start date
        if (result = parser(tokens[0], date, null)) != null
          if result.isAllDay
            date.setHours 0, 0, 0
          ret.isAllDay = result.isAllDay
          ret.eventTitle = result.eventTitle
          ret.startDate = if result.isValidDate then date else null
        # if no time
        if !ret.startDate and tokens.length >= 3
          # join the next 2 tokens to the current one
          tokensTmp = [ tokens[0] + tokens[1] + tokens[2] ]
          k = 3
          while k < tokens.length
            tokensTmp.push tokens[k]
            k++
          tokens = tokensTmp
        else
          break
      # parse the 2nd half of the date range, if it exists
      while !ret.endDate
        if tokens.length > 1
          date = new Date(date.getTime())
          # parse the end date
          if (result = parser(tokens[2], date, ret)) != null
            if ret.isAllDay
              date.setHours 0, 0, 0
            if result.eventTitle.length > ret.eventTitle.length
              ret.eventTitle = result.eventTitle
            ret.endDate = if result.isValidDate then date else null
        if !ret.endDate
          if tokens.length >= 4
            # join the next 2 tokens to the current one
            tokensTmp = [
              tokens[0]
              tokens[1]
              tokens[2] + tokens[3] + tokens[4]
            ]
            k = 5
            while k < tokens.length
              tokensTmp.push tokens[k]
              k++
            tokens = tokensTmp
          else
            ret.endDate = null
            break
      makeAdjustments ret.startDate, ret.endDate, ret.isAllDay, str, ret
      # get capitalized version of title
      if ret.eventTitle
        fillerWords = if readConfig('disableRanges') then patterns.fillerWords2 else patterns.fillerWords
        ret.eventTitle = ret.eventTitle.split(fillerWords)[0].trim()
        ret.eventTitle = ret.eventTitle.replace(/(?:^| )(?:\.|-$|by$|in$|at$|from$|on$|starts?$|for$|(?:un)?till?$|!|,|;)+/g, '').replace(RegExp(' +', 'g'), ' ').trim()
        match = str.match(new RegExp(helpers.escapeRegExp(ret.eventTitle), 'i'))
        if match
          ret.eventTitle = match[0].replace(RegExp(' +', 'g'), ' ').trim()
          # replace multiple spaces
          if ret.eventTitle == ''
            ret.eventTitle = null
      else
        ret.eventTitle = null
      if typeof Watson != 'undefined'
        Watson.postprocess ret
      ret
    _setNow: (newDate) ->
      nowDate = newDate
      return

  }
# Add AMD compatibility.
if typeof define == 'function' and define.amd
  define Sherlock
else if typeof module != 'undefined' and module.exports
  module.exports = Sherlock

# ---
# generated by js2coffee 2.1.0