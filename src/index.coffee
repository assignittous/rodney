# index.js

#wit = require "./lib/wit"
inquirer = require "inquirer"
require 'sugar'

#knwl = require("./lib/knwl").knwl
#console.log "Rodney says hello"

#wit.ai.parse("Send me this quarter's sales numbers")

#knwl.test ""

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