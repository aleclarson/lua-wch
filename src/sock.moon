Promise = require 'cqueues.promise'
events = require 'wch.events'
quest = require 'quest'
uuid = require 'uuid'
cq = require 'cqueues'

{:JSON} = require 'quest.inject'
{:EPIPE} = require 'cqueues.errno'
-- {:ENOENT, :ECONNREFUSED} = require 'cqueues.errno'
-- {:opendir, :CREATE} = require 'cqueues.notify'

HOME = os.getenv 'HOME'
WCH_DIR = HOME..'/.wch'
sock = quest.sock WCH_DIR..'/server.sock'

clientId = uuid!
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
  stream\on 'data', (event) ->
    name, args = event\match '^([^\n]+)\n(.+)\n\n$'
    events.emit name, JSON.decode args

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


--
-- let retries = 0, retryId
-- function reconnect(resolve, reject) {
--   if (fs.exists(SOCK_PATH)) {
--     console.log('sock.retry:', retries)
--     let fuzz = 1.25 - 0.5 * Math.random()
--     let delay = fuzz * 300 * Math.pow(2.2, ++retries)
--     retryId = setTimeout(async () => {
--       retryId = null
--       try {
--         await new Promise(connect)
--         retries = 0
--         resolve()
--       } catch(err) {
--         if (stream) {
--           reconnect(resolve, reject)
--         } else { // Closed by user
--           retries = 0
--           reject(err)
--         }
--       }
--     }, delay)
--   } else {
--     console.log('waiting for server...')
--     watcher = fs.watch(WCH_DIR, (evt, file) => {
--       if (file == SOCK_NAME) {
--         watcher.close()
--         watcher = null
--         reconnect(resolve, reject)
--       }
--     })
--     let {close} = watcher
--     watcher.close = function() {
--       close.apply(this, arguments)
--       if (!stream) { // Closed by user
--         reject(CloseError())
--       }
--     }
--   }
-- }
--
-- function CloseError() {
--   let err = Error('Closed by user')
--   err.code = 'ECONNRESET'
--   return err
-- }
