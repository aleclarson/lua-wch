Emitter = require 'emitter'

watched = {}
events = Emitter!

watch = (id, stream) ->
  watched[id] = stream

emit = (id, args) ->

  if id == 'watch'
    stream = watched[args[1].id]
    stream and stream\emit 'data', args[1].file
    return

  events\emit id, args and unpack args
  if events\len('*') > 0
    events\emit '*', id, args and unpack args

on = (id, fn) ->
  events\on id, fn
  dispose: -> events\off id, fn

return {
  :watch
  :emit
  :on
}
