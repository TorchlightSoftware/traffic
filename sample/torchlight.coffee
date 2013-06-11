should = require "should"
async = require "async"

traffic = require '..'
patience = 4000

traffic.visit "http://torchlightsoftware.com", (t, done) ->

  # enter chat
  t.drive [
    t.waitFor '.navLi', patience
    t.click '.navLi a'
    t.waitForText "Simplicity", patience

  ], done
