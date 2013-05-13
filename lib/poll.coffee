{tandoor} = require './util'

interval = 7

module.exports = tandoor (timeout, check, cb) ->
  started = new Date()

  verify = (value) ->
    if value then cb() else next()

  runner = ->

    if (timeout and timeout isnt Infinity) and (new Date() - started) > timeout
      cb(new Error "Timed out after #{timeout} ms.")

    # async check
    else if check.length is 1
      check (err, result) ->
        return cb err if err
        verify result

    # synch check
    else
      verify check()

  next = ->
    setTimeout runner, interval

  next()
