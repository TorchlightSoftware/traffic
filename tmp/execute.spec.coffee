require 'should'
execute = require './execute'
newPaneWindow = require './newPaneWindow'

Vein = require 'vein'
http = require 'http'

port = Math.floor Math.random() * 20000 + 8000

describe 'execute', (done)->
  it 'should execute a script on a window', (done)->
    veinServer = new Vein http.createServer().listen port
    newPaneWindow port, (window, veinClientName)->
      execute window, veinServer, veinClientName, {}, 'passthrough.value = 6 * 7;', (passthrough)->
        passthrough.value.should.eql 42
        veinServer.close()
        done()
