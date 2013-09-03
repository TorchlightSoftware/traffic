should = require "should"
async = require "async"

traffic = config.require 'lib/traffic'
patience = 6000

module.exports = ->
  traffic.visit "https://localhost:8443", (t, done) ->

    # enter chat
    t.drive [
      t.waitFor "#nameInput", patience
      t.fill "#nameInput", 'Chat Agent'
      t.click "#startChat"
      t.waitFor "span.message", patience

    ], (err) ->
      return done err if err

      # send a message
      sendMessage = (loopIndex, loopId) -> [
        t.print "loopId: #{loopId}".red
        t.fill '.new-message', loopId
        t.click '.submit-button'
        t.setTimer 'message'
        t.waitForText loopId, patience
        t.diffTimer 'message'
      ]

      # send messages
      t.loop t.forever, sendMessage, done
