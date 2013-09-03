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
