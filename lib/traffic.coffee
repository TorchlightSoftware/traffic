phantom = require "node-phantom"
poll = require '../lib/poll'
{tandoor} = require '../lib/util'

helpers = (page) ->
  constructed =
    poll: poll

    exists: tandoor (selector, done) ->
      script = "function(){return !!$('#{selector}').length;}"
      page.evaluate script, done

    html: tandoor (selector, done) ->
      script = "function(){return $('#{selector}').html();}"
      page.evaluate script, done

    text: tandoor (selector, done) ->
      script = "function(){return $('#{selector}').text();}"
      page.evaluate script, done

    fill: tandoor (selector, value, done) ->
      script = "function(){return $('#{selector}').val('#{value}');}"
      page.evaluate script, done

    hasText: tandoor (selector, value, done) ->
      script = "function(){return ~$('#{selector}').text().indexOf('#{value}');}"
      page.evaluate script, done

    click: tandoor (selector, done) ->
      script = "function(){return $('#{selector}').click();}"
      page.evaluate script, done

    print: tandoor (target, done) ->
      if (typeof target) is 'function'
        target (err, value) ->
          console.log value
          done()
      else
        console.log target
        done()

    printPage: (done) ->
      constructed.html 'body', (err, body) ->
        console.log {err, body}
        done()

module.exports = traffic =
  visit: (url, script) ->
    phantom.create (err, ph) ->
      finished = (err) ->
        console.log {err} if err
        ph?.exit()

      return finished err if err

      ph.createPage (err, page) ->
        return finished err if err
        page['onConsoleMessage'] = (args...) -> console.log '*:', args...
        page['onError'] = ([err, stack]) ->
          trace = stack.map(({file, line})-> "    #{file}:#{line}").join '\n'
          console.log "*ERROR: #{err}\n#{trace}"
        #page['onResourceRequested'] = ([req]) -> console.log "*#{req.method}: #{req.url}"

        # open url
        page.open url, (err, status) ->
          return finished err if err

          # and call script
          script status, helpers(page), finished
