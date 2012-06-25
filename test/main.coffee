async = require 'async'
http = require 'http'
should = require 'should'
van = new (require '../lib/main')

describe 'traffic', ->

  before (done) ->
    http.createServer((req, res) -> res.end '<p id="message">hello</p>').listen 4042, ->
      van.start 8084, done

  it 'loads a page', (done) ->
    van.load 'http://localhost:4042', done

  it 'retrieves a value from the page', (done) ->
      async.series [
        van.load 'http://localhost:4042'

        van.drive (next) ->
          next null, $('#message').text() # executed client side

      ], (err, data) ->
        data[1].should.equal 'hello'
        done()
