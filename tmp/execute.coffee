module.exports = (paneWindow, veinServer, veinClientName, passthrough={}, command, cb)->
  getId = ->
    rand = -> (((1 + Math.random()) * 0x10000000) | 0).toString 16
    "service#{rand()+rand()+rand()}"

  #verify uniqueness and set up callback
  newService = getId()
  veinServer.add newService, (res, callbackInfo)->
    veinServer.remove newService
    res.send "ack"
    cb callbackInfo


  #wrap command
  passthroughString = JSON.stringify passthrough
  newCommand = "var passthrough = JSON.parse(\"#{passthroughString}\");\n"
  newCommand = newCommand.concat "#{command}\n"
  newCommand = newCommand.concat "#{veinClientName}.refresh(function(services){\n"
  newCommand = newCommand.concat "\t#{veinClientName}.#{newService}(passthrough, function(ack){console.log(\"server says \" + ack)});"
  newCommand = newCommand.concat "\n});"

  #execute
  paneWindow.execute newCommand
