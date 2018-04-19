Emitter = require 'emitter'
events = require 'wch.events'
sock = require 'wch.sock'
cq = require 'cqueues'

class WatchStream extends Emitter
  new: (root, opts) =>
    super!
    @root = root
    @opts = opts

  start: =>
    sock\connect!\get!

    req = sock\request 'POST', '/watch',
      'x-client-id': sock.id

    print req.headers\dump!

    print 'starting stream...'
    res, err = req\send {root: @root, opts: @opts}
    error err if err ~= nil

    print res.headers\dump!

    print 'stream started!'
    res, err = res\json!
    error err if err ~= nil

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
