Promise = require 'cqueues.promise'
events = require 'wch.events'
quest = require 'quest'
uuid = require 'uuid'
rpc = require 'json-rpc'
cq = require 'cqueues'

{:JSON} = require 'quest.inject'
{:EPIPE} = require 'cqueues.errno'
-- {:ENOENT, :ECONNREFUSED} = require 'cqueues.errno'
-- {:opendir, :CREATE} = require 'cqueues.notify'

rpc.JSON = JSON

HOME = os.getenv 'HOME'
WCH_DIR = HOME..'/.wch'
sock = quest.sock WCH_DIR..'/server.sock'

clientId = tostring uuid!
connected = nil  -- connect promise

connect = ->
  error 'must be in a cqueue' unless cq.running!

  req = sock\request 'GET', '/events',
    'x-client-id': clientId

  sock.state = 'connecting'
  stream, err, eno = req\send!

  -- if eno == ENOENT or eno == ECONNREFUSED
  -- TODO: watch the server's socket path

  if err ~= nil
    -- TODO: try reconnecting after a delay
    connected, promise = nil, connected
    sock.state = 'closed'
    promise\set false, err
    return

  sock.id = clientId
  sock.state = 'connected'

  stream.queue = cq.running!
  stream\on 'data', rpc.decoder(events.emit)

  -- TODO: auto-reconnect if not closed by user
  -- TODO: abort reconnect if closed by user
  stream\on 'end', ->
    connected = nil
    sock.state = 'closed'
    events.emit 'close'

  stream\on 'error', (err, eno) ->
    -- reconnect! if eno == EPIPE
    events.emit 'error', {err}

  connected\set true
  events.emit 'connect'
  return

----------------------------------
-- EXPORTS
----------------------------------

sock.state = 'closed'

sock.connect = ->
  unless connected
    connected = Promise.new!
    cq.running!\wrap connect
  connected

sock.close = ->
  error 'not yet implemented'

return sock
