Pane = require 'pane'
{readFile} = require 'fs'
{join} = require 'path'

module.exports = (veinPort, cb)->

  opt =
    title: 'Test'
    height: 500
    width: 500
    html: 'Hello world!'

  paneWindow = new Pane opt

  process.nextTick ->

    paneWindow.html 'Hello world!', 'http://localhost'

    veinName = "trafficVein#{veinPort}#{Math.floor(Math.random() * 10000)}"
    veinSuccess = "#{veinName} started successfully"

    paneWindow.on 'console', (msg, line, file) ->
      console.log msg
      cb paneWindow, veinName if msg is veinSuccess

    veinPath = join __dirname, 'node_modules/vein/vein.js'
    readFile veinPath, 'ascii', (err, data)->
      throw err if err
      paneWindow.execute data
      paneWindow.execute "var #{veinName} = new Vein({port: #{veinPort}, transports: ['websocket']});"
      readyCommand = "#{veinName}.ready(function (){ console.log(\"#{veinSuccess}\"); });"
      paneWindow.execute readyCommand
