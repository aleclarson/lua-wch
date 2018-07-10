Emitter = require 'emitter'

events = Emitter!

emit = (id, data) ->
  events\emit id, data
  if events\len('*') > 0
    events\emit '*', id, data

on = (id, fn) ->
  events\on id, fn
  dispose: -> events\off id, fn

return {
  :emit
  :on
}
