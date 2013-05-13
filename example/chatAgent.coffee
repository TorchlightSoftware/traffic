async = require "async"
random = config.require 'lib/random'
{visit} = config.require 'lib/traffic'

module.exports = ->

  # load the page
  visit "http://localhost:4000", (status, helpers, done) ->
    {poll, exists, html, text, fill, hasText, click, print, printPage} = helpers

    async.series [

      # wait for page load
      poll 200, exists('#nameInput')

      # enter chat
      fill '#nameInput', 'Bob'
      click '#startChat'
      poll 200, exists('.chatBox')

    ], (err) ->
      return done err if err

      poll Infinity, ((next) ->
        message = random()
        startTime = new Date
        async.series [

          # send a message
          fill '.new-message', message
          click '.submit-button'
          poll 200, hasText('.message', message)

        ], (err) ->
          elapsed = (new Date) - startTime
          console.log "Sent message in #{elapsed} ms."
          next err

      ), done
