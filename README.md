## Information

<table>
<tr>
<td>Package</td><td>Traffic</td>
</tr>
<tr>
<td>Description</td>
<td>Browser automation tool for testing and scraping.</td>
</tr>
<tr>
<td>Node Version</td>
<td>>= 0.6</td>
</tr>
</table>

## Usage

This is still pretty rough around the edges, but it shows that client side code can be executed in an asyncronous fashion, with a callback being triggered server side.  Sugary syntax is coming soon.

```coffee-script
should = require 'should'
van = new (require '../lib/main')

http.createServer((req, res) -> res.end '<p id="message">hello</p>').listen 4042, ->
  van.start 8084, ->
    van.load 'http://localhost:4042', ->

      van.drive ((next) ->
        next null, $('#message').text() # executed client side
      ), (err, data) ->
        data.should.equal 'hello'
        done()
```

## LICENSE

(MIT License)

Copyright (c) 2012 Fractal <contact@wearefractal.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
