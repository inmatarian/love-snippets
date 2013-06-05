
local observer = require 'observer'

local unittests = {

  ["As Class"] = function()
    local o = observer.new()
    assert(o)
    assert(o.on)
    assert(o.off)
    assert(o.trigger)
  end,

  ["As Mixin"] = function()
    local o = {}
    observer.mixin(o)
    assert(o.on)
    assert(o.off)
    assert(o.trigger)
  end,

  ["Triggering Signal"] = function()
    local o = observer.new()
    local x, y = 0, 0
    o:on("signal", function(self, v) x = v end)
    o:on("signal", function(self, v) y = v + 1 end)
    o:trigger("signal", 27)
    assert(x==27)
    assert(y==28)
  end,
    
  ["Direct Call"] = function()
    local o = observer.new()
    local x, y = 0, 0
    o:on("signal", function(self, v) x = v end)
    o:on("signal", function(self, v) y = v + 1 end)
    o:signal(42)
    assert(x==42)
    assert(y==43)
  end,

  ["Removals"] = function()
    local o = observer.new()
    local x, y = 0, 0
    local ymodifier = function(self, v) y = v + 1 end
    o:on("signal", function(self, v) x = v end)
    o:on("signal", ymodifier)
    o:signal(42)
    o:off("signal", ymodifier)
    o:signal(27)
    assert(x==27)
    assert(y==43)
  end,

  ["Priorities"] = function()
    local o = observer.new()
    local x = 0
    o:on("signal", observer.PRIORITY_MAXIMUM, function(self, v) x = x + v end)
    o:on("signal", observer.PRIORITY_MINIMUM, function(self, v) x = x * v end)
    o:signal(10)
    assert(x==100)
  end,
}

for name, test in pairs(unittests) do
  io.write(string.format("Performing test: %-30s\t", name))
  local success, message = pcall(test)
  if success then
    io.write("Ok.\n")
  else
    io.write("Failed!\n")
    io.write(string.format("%s\n\n", message))
  end
end

