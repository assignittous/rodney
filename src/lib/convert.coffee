###

# Convert

conversion functions

###

require 'sugar'
fs = require('fs')

logger = require('../lib/logger.js').Logger
CSON = require('cson')

exports.Convert = 

  csvHeader: (object)->
    if Array.isArray(object)

      header = object.map (x)->
        return '"' + x + '"'
    else

      header = Object.keys(object).map (x)->
        return '"' + x + '"'
    header
  csvRowSanitize: (object, attributes)->

    if attributes?
      #console.log "select only"
      #console.log attributes
      object = Object.select(object, attributes)
      #console.log object

    return Object.values(object).map (x)->
      

      if isNaN(x) 
        out = "\"#{x.replace(/\"/g,'\"\"')}\""
        return out
      else
        return x

  objectToCsv: (data)->
    # header
    targetRecords = @csvHeader(data) + '\n'
    targetRecords += @csvRowSanitize(data)

  arrayToCsv: (data, attributes)->
    that = @
    targetRecords = @csvHeader(attributes || data.first())  + '\n'
    data.each (o)->
      targetRecords += that.csvRowSanitize(o, attributes) + "\n"
    targetRecords


  fileExtension: (path)->
    elements = path.split('.')
    return elements.last()

  file: (sourcePath, targetPath)->
    switch @fileExtension(sourcePath)
      when 'csv'
        console.log 'csv'
        
      when 'cson', 'json'
        console.log 'cson/json'
        sourceRecords = CSON.parseFile(sourcePath)

      when 'xml'
        console.log 'xml'
    #console.log "SOURCE:" + sourcePath
    #console.log sourceRecords


    switch @fileExtension(targetPath)
      when 'csv'
        
        sanitized = Object.keys(sourceRecords.first()).map (x)->
          return '"' + x + '"'
        targetRecords = sanitized.join(',') + '\n' 
        sourceRecords.each (o)->
          sanitized = Object.values(o).map (x)->
            if isNaN(x)
              console.log "-----------------------"
              out = "\"#{x.replace(/\"/g,'\"\"')}\""
              console.log x
              console.log
              console.log out
              return out
            else
              return x




          targetRecords = targetRecords + sanitized.join(',') + '\n'
        # todo : sanitizer
        console.log 'csv'
        #sourceRecords.each
        #console.log targetRecords
      when 'cson'
        console.log 'cson'
        targetRecords = CSON.createCSONString(sourceRecords)
        #sourceRecords = CSON.parseCSONFile(sourcePath)
      when 'json'
        console.log 'json'
        targetRecords = CSON.createJSONString(sourceRecords)
      when 'xml'
        console.log 'xml'
      else
        targetRecords = null

    if targetRecords?
      console.log targetRecords
      fs.writeFileSync(targetPath, targetRecords)
    



  # Produce a date sid
  dateSid: ()->
    Date.create().format("{yyyy}{MM}{dd}{HH}{mm}{ss}{fff}")

  # Check if a path has extension, if not add it
  checkExtension: (path, ext)->
    if path.endsWith(ext)
      return path
    else
      return "#{path}.#{ext}"

  xmlToJade: (path, jadePath)->
    logger.info "xmltojade"
    fileContents = fs.readFileSync path, { encoding: 'utf8' }
    
    fileContents = fileContents.replace('<?xml version="1.0" encoding="UTF-8" standalone="no"?>',"")

    # remove close tags

    #regexes = []
    regexes = []


    regexes.push
      name: "Strip close tags"
      regex: new RegExp("</(.*?)>","g")
      replacement: ""

    regexes.push
      name: "Close empty elements"
      regex: new RegExp("/>","g")
      replacement: ">"

    regexes.push
      name: "Convert to jade"
      regex: new RegExp("<(.*?) (.*)>","g")
      replacement: "$1($2)"

    regexes.push
      name: "Comma separate attributes"
      regex: new RegExp('" (.*?=)',"g")
      replacement: '", $1'
    regexes.push
      name: "Set tabs to 2 spaces"
      regex: new RegExp('    ',"g")
      replacement: '  '
    regexes.each (o)->
      #onsole.log "asdfasdfasdf"
      logger.info o.name
      #logger.info o # fileContents
      fileContents = fileContents.replace o.regex, o.replacement

    fileContents = '<?xml version="1.0" encoding="UTF-8"?>\n' + fileContents
    #regex = new RegExp("<(.*?) (.*)/>", "g")
    #cleansed = fileContents.replace(regex, "<$1 $2></$1>")  

    lines = fileContents.split('\n')

    fileContents = ''
    lines.each (line)->
      if !line.isBlank()
        fileContents += line + '\n'
    logger.info "Strip blank lines"
    fs.writeFileSync(jadePath, fileContents)
    logger.info "Wrote to #{jadePath}"
  xmlTidy: (path, jadePath)->
    fileContents = fs.readFileSync path, { encoding: 'utf8' }
    regex = new RegExp("<(.*?) (.*)/>", "g")
    cleansed = fileContents.replace(regex, "<$1 $2></$1>")    
    fs.writeFileSync(jadePath, cleansed)

  deleteFileIfExists: (path)->
    try
      fs.openSync path, 'r'
      fs.unlinkSync path
      logger.info "Deleted #{path}"
    catch e
      console.log "can't open"
    finally
      console.log "finally"