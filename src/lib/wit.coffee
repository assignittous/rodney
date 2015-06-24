# wit.coffee

wit = require 'node-wit'

configuration = require('../lib/configuration').Configuration

exports.ai =
  parse: (query)->
    console.log "wit says hi"
    ACCESS_TOKEN = configuration.current.token
    wit.captureTextIntent ACCESS_TOKEN, query, (err, res) ->
      console.log 'Response from Wit for text input: '
      if err
        console.log 'Error: ', err
      console.log JSON.stringify(res, null, ' ')
      return    