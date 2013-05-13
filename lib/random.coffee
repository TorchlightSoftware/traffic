module.exports = ->
  digit = -> ((Math.random() * 16) | 0).toString 16
  buffer = []
  for n in [1..16]
    buffer.push digit()

  return buffer.join ''
