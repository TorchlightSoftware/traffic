module.exports = util =

  # return random 16 digits
  random: ->
    digit = -> ((Math.random() * 16) | 0).toString 16
    buffer = []
    for n in [1..16]
      buffer.push digit()

    return buffer.join ''

  curry: (fn, args...) -> fn.bind fn.prototype, args...

  getType: (obj) -> Object.prototype.toString.call(obj).slice 8, -1

  # return a hash containing only the keys provided
  select: (hash, keys...) ->
    return {} unless util.getType(hash) is 'Object'
    Object.findAll hash, (k) -> k in keys

  reject: (hash, keys...) ->
    return {} unless util.getType(hash) is 'Object'
    Object.findAll hash, (k) -> k not in keys

  # given a function, wrap it in naan and curry, then cook it
  # In English: Enables autocurrying, so if you haven't provided the callback
  # yet you'll get a curried function instead of premature execution.
  tandoor: (fn) ->
    naan = (args...) ->
      [_..., last] = args
      unless (fn.length > 0 and args.length >= fn.length) or (fn.length == 0 and util.getType(last) is 'Function')
        return util.curry naan, args...
      fn args...

    return naan

  getString: (thing) ->
    if thing then thing.toString() else null
