# wch v0.0.1

Lua client for [wch](https://github.com/aleclarson/wch).

```lua
local wch = require('wch')

-- must be called in a cqueue!
local stream = wch.stream(os.getenv('PWD'), {
  include = {'src/*.moon'};
})

-- listen for file events
stream:on('data', function(file)
  print('path =', file.path)
  print('exists =', file.exists)
  print('new =', file.new)
end)

-- when you're done
stream:stop()

-- listen for plugin events
local sub = wch.on('*', function(id, ...)
  print(id..' =>', ...)
end)

-- when you're done
sub:dispose()
```
