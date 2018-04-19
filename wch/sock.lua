local Promise = require('cqueues.promise')
local events = require('wch.events')
local quest = require('quest')
local uuid = require('uuid')
local cq = require('cqueues')
local JSON
JSON = require('quest.inject').JSON
local EPIPE
EPIPE = require('cqueues.errno').EPIPE
local HOME = os.getenv('HOME')
local WCH_DIR = HOME .. '/.wch'
local sock = quest.sock(WCH_DIR .. '/server.sock')
local clientId = uuid()
local connected = nil
local connect
connect = function()
  if not (cq.running()) then
    error('must be in a cqueue')
  end
  local req = sock:request('GET', '/events', {
    ['x-client-id'] = clientId
  })
  sock.state = 'connecting'
  local stream, err, eno = req:send()
  if err ~= nil then
    local promise
    connected, promise = nil, connected
    sock.state = 'closed'
    promise:set(false, err)
    return 
  end
  sock.id = clientId
  sock.state = 'connected'
  stream.queue = cq.running()
  stream:on('data', function(event)
    local name, args = event:match('^([^\n]+)\n(.+)\n\n$')
    return events.emit(name, JSON.decode(args))
  end)
  stream:on('end', function()
    connected = nil
    sock.state = 'closed'
    return events.emit('close')
  end)
  stream:on('error', function(err, eno)
    return events.emit('error', {
      err
    })
  end)
  connected:set(true)
  events.emit('connect')
end
sock.state = 'closed'
sock.connect = function()
  if not (connected) then
    connected = Promise.new()
    cq.running():wrap(connect)
  end
  return connected
end
sock.close = function()
  return error('not yet implemented')
end
return sock