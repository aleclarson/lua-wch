local Emitter = require('emitter')
local events = Emitter()
local emit
emit = function(id, data)
  events:emit(id, data)
  if events:len('*') > 0 then
    return events:emit('*', id, data)
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
  emit = emit,
  on = on
}