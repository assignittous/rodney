require 'sugar'


pkg = require('./package.json')
program = require('commander')
#init = require("../lib/init").Init
logger = require('./lib/logger').Logger
inquirer = require "inquirer"
config = require('./lib/configuration').Configuration


rodney = require './lib/rodney'

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
      default: "bye"

    }
  ]


  quit = false

  ask = ()->
    if !quit
      inquirer.prompt prompt, (response)->
        if ["quit","exit","bye"].any(response.request.toLowerCase())
          quit = true
        else
          console.log response.request
          ask()
    else
      console.log "QUIT"

  ask()



result = program.parse(process.argv)

