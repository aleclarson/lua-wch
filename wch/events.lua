local Emitter = require('emitter')
local watched = { }
local events = Emitter()
local watch
watch = function(id, stream)
  watched[id] = stream
end
local emit
emit = function(id, args)
  if id == 'watch' then
    local stream = watched[args[1].id]
    local _ = stream and stream:emit('data', args[1].file)
    return 
  end
  events:emit(id, args and unpack(args))
  if events:len('*') > 0 then
    return events:emit('*', id, args and unpack(args))
  end
end
local on
on = function(id, fn)
  events:on(id, fn)
  return {
    dispose = function()
      return events:off(id, fn)
    end
  }
end
return {
  watch = watch,
  emit = emit,
  on = on
}