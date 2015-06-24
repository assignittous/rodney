###

# Logger

Outputs messages to the console.

###
'use strict'

chalk = require('chalk')
require 'sugar'

CSON = require('cson')
cwd = process.env.PWD || process.cwd()
#logger = require('../lib/logger').Logger

exports.Logger = {
  log: []
  init: ()->
    @log = []
    return this
  completed: ()->
    return @log.join("\n")
  append: (type, msg)->
    entry = "[#{Date.create().format('{HH}:{mm}:{ss}')}] #{type} #{msg}"
    @log.push chalk.stripColor(entry)
    console.log entry
  debug: (msg)->
    @append chalk.bgWhite.black(" DEBUG "), msg    
  info: (msg)->
    @append chalk.bgWhite.black(" INFO "), msg
  error: (msg)->
    @append chalk.bgRed.black(" ERROR "), msg
  warn: (msg)->
    @append chalk.bgYellow.black(" WARN "), msg
  bot: (msg)->
    @append chalk.bgGreen.white(" BOT "), msg
  shell: (msg)->
    @append chalk.bgBlue.white(" SHELL: "), ""
    console.log msg
  exec: (msg)->
    @append chalk.bgBlue.white(" EXEC "), msg
  stub: (msg)->
    @append chalk.bgRed.black(" STUB "), msg
  todo: (msg)->
    @append chalk.bgRed.black(" TODO "), msg  

}.init()