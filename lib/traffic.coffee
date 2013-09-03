fs = require "fs"
wd = require "wd"
colors = require "colors"
poll = require '../lib/poll'
{tandoor} = require '../lib/util'
logger = require '../lib/logger'
browser = wd.remote()
async = require "async"
{random} = require '../lib/util'

browser.on "status", (info) ->
  console.log info.cyan

browser.on "command", (meth, path, data) ->
  console.log " > " + meth.yellow, path.grey, data or ""

timers = {}

# these helpers are wrappers around the 'wd' API.  See reference here:
# https://github.com/admc/wd#supported-methods
helpers =

  drive: tandoor (tasks, done) ->
    async.series tasks, done

  # loop through and run 'tasks' array repeatedly until 'condition'
  # evaluates to false or returns an error.
  # Condition is a function which takes a callback in the form of
  #     (err, result) ->
  # and is expected to call it with the results of its check.
  # Condition also receives 'loopId'
  loop: tandoor (condition, tasks, done) ->
    loopIndex = -1
    loopId = null

    recur = (err) ->
      return done err if err
      loopId = random()
      loopIndex++

      driver = (err, result) ->
        return done err if err
        return done() unless result
        helpers.drive tasks(loopIndex, loopId), recur

      condition driver, loopIndex, loopId

    recur()

  # helper to loop forever
  # just pass it in as the 'condition' arg to loop
  forever: (check) -> check null, true

  # helper to never loop
  never: (check) -> check null, false

  # Just in case you need to poll for something,
  # i.e. it's not supported otherwise in the API
  # (timeout, check, done) ->
  poll: poll

  setTimer: tandoor (tag, next) ->
    timers[tag] = new Date
    next()

  diffTimer: tandoor (tag, next) ->
    elapsed = (new Date) - timers[tag]
    console.log "Completed #{tag} in #{elapsed} ms.".yellow
    next()

  # (selector, timeout, done) ->
  waitFor: tandoor browser.waitForElementByCssSelector.bind(browser)

  waitForText: tandoor (text, timeout, done) ->
    browser.waitForElementByXPath "//*[text()='#{text}']", timeout, done

  # (script, done) ->
  eval: browser.safeEval.bind(browser)

  # (selector, done) ->
  exists: tandoor browser.hasElementByCssSelector.bind(browser)

  # (selector, done) ->
  text: tandoor (selector, done) ->
    browser.elementByCssSelector selector, (err, el) ->
      return done err if err
      el.text done

  html: tandoor (selector, done) ->
    helpers.eval "document.querySelector('#{selector}').outerHTML", done

  fill: tandoor (selector, text, done) ->
    browser.elementByCssSelector selector, (err, el) ->
      return done err if err
      el.sendKeys text, done

  click: tandoor (selector, done) ->
    browser.elementByCssSelector selector, (err, el) ->
      return done err if err
      el.click done

  print: tandoor (target, done) ->
    if (typeof target) is 'function'
      target (err, value) ->
        console.log value
        done()
    else
      console.log target
      done()

  printPage: (done) ->
    helpers.html 'html', (err, html) ->
      console.log html
      done err

  takeScreenshot: (done) ->
    browser.takeScreenshot (err, ssData) ->
      screenshot = new Buffer ssData, 'base64'
      filename = __dirname + '/../tmp/screenshots/ss1.png'
      fs.writeFile filename, screenshot, 'binary', done

module.exports = traffic =
  visit: (url, script) ->
    browser.init {
      browserName: "chrome"
      tags: ["examples"]
      name: "This is an example test"
    }, (err) ->

      # exit gracefully
      finished = (err) ->
        if err
          seleniumError = err?.cause?.value?.message
          errorMessage = err?.message
          console.log "Error: #{seleniumError or errorMessage or err}".red
          helpers.printPage ->
            browser?.quit()

        else
          browser?.quit()
          console.log "Done!".green

      return finished err if err

      # open url
      browser.get url, (err) ->
        return finished err if err

        # and call script
        script helpers, finished
