require 'sugar'


pkg = require('./package.json')
program = require('commander')
#init = require("../lib/init").Init
logger = require('./lib/logger').Logger
inquirer = require "inquirer"

CSON = require('cson')
cwd = process.env.PWD || process.cwd()


rodney = require('./lib/rodney').Rodney

noOp = ()-> 
  console.log "Nothing ran, couldn't understand your command"

# version
program
.version(pkg.version, '-v, --version')

subcommand = { }


config = program.command 'config'
config.description 'Create a new thing'
config.action ()->
  console.log "This command dumps the configuration"

# ## `knodeo help`

help = program.command 'help'
help.description 'Create a new thing'
help.action ()->
  console.log help






subcommand.init = program.command 'init'
subcommand.init.description 'Initialize knodeo for the current working folder'
subcommand.init.action ()->

  #init.all()


subcommand.console = program.command 'console'

subcommand.console.action ()->

  prompt = [
    {
      type: 'input'
      name: 'request'
      message: 'Say Something to Rodney'
      default: "Send me last year's income statement"

    }
  ]


  quit = false

  ask = ()->
    if !quit
      inquirer.prompt prompt, (response)->
        if ["quit","exit","bye"].any(response.request.toLowerCase())
          quit = true
        else
          rodney.parse response.request
          ask()
    else
      console.log "QUIT"

  ask()

subcommand.batch = program.command 'batch'

subcommand.batch.action ()->

  batch = CSON.parseCSONFile("#{cwd}/samples.cson")

  console.log batch

  batch.each (item)->
    rodney.parse item

result = program.parse(process.argv)

