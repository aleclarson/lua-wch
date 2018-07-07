Emitter = require 'emitter'
events = require 'wch.events'
sock = require 'wch.sock'

resolve = (path) ->
  if path\sub(1, 1) ~= '/'
    return os.getenv('PWD')..'/'..path
  return path

class WatchStream extends Emitter
  new: (root, opts) =>
    super!
    @root = resolve root
    @opts = opts

  start: =>
    sock\connect!\get!

    req = sock\request 'POST', '/watch',
      'x-client-id': sock.id

    res, err, eno = req\send {root: @root, opts: @opts}
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

wch.stream = (root, opts) ->
  stream = WatchStream root, opts
  return stream\start!

return wch
