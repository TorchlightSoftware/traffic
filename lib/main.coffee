Pane = require 'pane'
http = require 'http'
Vein = require 'vein'
{readFileSync} = require 'fs'
{join} = require 'path'
should = require 'should'

class Traffic
  start: (port, next) ->
    @port = port

    # start vein server
    server = http.createServer().listen @port
    @vein = new Vein server

    @driveCounter = 0
    @handlers = {}

    @vein.add 'transmit', (res, event, error, data) =>
      @handlers[event] error, data
      res.send status: 'success'

    next()

  load: (url, next) ->

    # curry for support with async libraries
    return @load.bind @, url unless next?

    return next 'call init first' unless @vein?

    JQUERY = join __dirname, './jquery.js'
    VEIN_CLIENT = join __dirname, '../node_modules/vein/vein.js'

    # create new browser
    @browser = new Pane
      title: 'Test'
      url: url
      width: 400
      height: 300
    @browser.move 0, 0

    # set up logging
    @browser.on 'console', (message) -> console.log "client: #{message}"
    @handlers.init_complete = next

    #initialize vein client
    veinClient = readFileSync VEIN_CLIENT, 'utf8'
    jquery = readFileSync JQUERY, 'utf8'
    clientInit = ->
      vein = new Vein
        host: 'localhost'
        port: @port

      vein.ready (services) ->
        vein.transmit 'init_complete', -> # empty callback

      window._traffic = vein

    @browser.on 'loaded', =>
      @browser.execute "#{veinClient}#{jquery}(#{clientInit}).apply(#{JSON.stringify {port: @port}});"

  drive: (fn, next) ->

    # if it's a string just execute it
    return @browser.execute fn if @browser and typeof fn is 'string'

    # curry for support with async libraries
    return @drive.bind @, fn unless next?

    return next 'call load first' unless @browser?

    # get a unique id for this 'drive' instance
    id = "drive#{@driveCounter}"
    @driveCounter += 1

    # wire up a server side handler to receive the 'done' signal
    @handlers[id] = next

    # pass a callback that will notify the server
    script = "var id='#{id}';(#{fn})(#{(err, data)->window._traffic.transmit id, err, data, ->});"
    @browser.execute script

module.exports = Traffic
