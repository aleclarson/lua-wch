Emitter = require 'emitter'
events = require 'wch.events'
sock = require 'wch.sock'

resolve = (path) ->
  if path\sub(1, 1) ~= '/'
    return os.getenv('PWD')..'/'..path
  return path

class WatchStream extends Emitter
  new: (dir, query) =>
    super!
    @dir = resolve dir
    @query = query

  start: =>
    sock\connect!\get!

    req = sock\request 'POST', '/watch',
      'x-client-id': sock.id

    res, err, eno = req\send {dir: @dir, query: @query}
    error err if err
    assert res.ok

    res, err = res\json!
    error err if err

    events.watch res.id, self
    return self

  stop: =>
    error 'not yet implemented'

----------------------------------
-- EXPORTS
----------------------------------

wch = {}

wch.on = events.on

wch.stream = (dir, query) ->
  stream = WatchStream dir, query
  return stream\start!

return wch
