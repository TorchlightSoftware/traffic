# Traffic

A DSL for browser automation.

# Setup

```bash
npm install -g sv-selenium
install_selenium
start_selenium

npm install traffic
```

# Usage

```javascript
  var should = require("should"),
    async = require("async"),
    traffic = config.require('lib/traffic'),
    patience = 6000;

    traffic.visit("https://localhost:8443", function(t, done) {
      t.drive([
          t.waitFor("#nameInput", patience)
        , t.fill("#nameInput", 'Chat Agent')
        , t.click("#startChat")
        , t.waitFor("span.message", patience)

      ], function(err) {
        if (err) {return done(err);}

        var sendMessage = function(loopIndex, loopId) {
          return [
              t.print(("loopId: " + loopId).red)
            , t.fill('.new-message', loopId)
            , t.click('.submit-button')
            , t.setTimer('message')
            , t.waitForText(loopId, patience)
            , t.diffTimer('message')];
        };

        t.loop(t.forever, sendMessage, done);
      });
    });
```

# API

## Load a web page

* visit

## Initiate a process

* drive (tasks, done)
* loop (condition, tasks, done)

## Perform commands

* setTimer (tag, next)
* diffTimer (tag, next)
* waitFor (selector, timeout, next)
* waitForText (text, timeout, next)
* eval (script, done)
* exists (selector, done)
* text (selector, done) # getText
* html (selector, done) # getHtml
* fill (selector, text, done)
* click (selector, done)
* print (target, done)
* printPage (done)
* takeScreenshot (done)

## Helpers

* forever # condition for loop
* never # condition for loop
* poll (timeout, check, done)
