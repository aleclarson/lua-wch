local Emitter = require('emitter')
local events = require('wch.events')
local sock = require('wch.sock')
local cq = require('cqueues')
local WatchStream
do
  local _class_0
  local _parent_0 = Emitter
  local _base_0 = {
    start = function(self)
      sock:connect():get()
      local req = sock:request('POST', '/watch', {
        ['x-client-id'] = sock.id
      })
      print(req.headers:dump())
      print('starting stream...')
      local res, err = req:send({
        root = self.root,
        opts = self.opts
      })
      if err ~= nil then
        error(err)
      end
      print(res.headers:dump())
      print('stream started!')
      res, err = res:json()
      if err ~= nil then
        error(err)
      end
      events.watch(res.id, self)
      return self
    end,
    stop = function(self)
      return error('not yet implemented')
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, root, opts)
      _class_0.__parent.__init(self)
      self.root = root
      self.opts = opts
    end,
    __base = _base_0,
    __name = "WatchStream",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  WatchStream = _class_0
end
local wch = { }
wch.on = events.on
wch.stream = function(root, opts)
  local stream = WatchStream(root, opts)
  return stream:start()
end
return wch