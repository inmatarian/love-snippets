-- Observer
-- See the included License file for copyright information.
--
-- Use it as a Class with .new
-- Use it as a Mixin/Component with .mixin
--
-- The API attempts to be fluent, meaning that the on/off/trigger
-- calls will return the object for chaining
--   Example: object:on("signal", callback_a):on("signal", callback_b)

local ASSERT_MSG = "existing function in handler slot: "
local setmetatable, type, remove = setmetatable, type, table.remove

local observer = {
  PRIORITY_MAXIMUM = 4, 
  PRIORITY_HIGH = 3,
  PRIORITY_NORMAL = 2,
  PRIORITY_LOW = 1,
  PRIORITY_MINIMUM = 0,
}

local PRIORITY_DEFAULT = observer.PRIORITY_NORMAL

local observer_mt = {
  __index = observer
}

local handler_mt = {
  __call = function(handler, instance, ...)
    local cache = handler.cache
    local N = #handler
    for i = 1, N do cache[i] = handler[i] end
    for i = 1, N do
      cache[i].callback(instance, ...) 
      cache[i] = nil
    end
    return instance
  end
}

local function prioritySorting(a, b)
  return b.priority < a.priority
end

local function newHandler()
  return setmetatable({cache={}}, handler_mt)
end

-- Register a callback function for a message
--   Example: object:on("signal", callback_function)
--
-- priority is an optional number used for sorting
-- callback function will get the subject of the observer
--   passed as the first parameter
function observer.on(instance, message, priority, callback)
  if callback == nil then
    callback = priority
    priority = PRIORITY_DEFAULT
  end
  local handler = instance[message]
  if handler == nil then
    handler = newHandler()
    instance[message] = handler
  end
  assert(type(handler)=="table", ASSERT_MSG..message)
  handler[#handler+1] = {callback=callback, priority=priority}
  table.sort(handler, prioritySorting)
  return instance
end

-- Removes a callback, or all callbacks, for a message
--   Example: object:off("signal")
--   Example: object:off("signal", callback_function)
--
-- callback must be the same function passed to `on`
function observer.off(instance, message, callback)
  local handler = instance[message]
  if type(handler)=="table" then
    for i = #handler, 1, -1 do
      if (callback==nil) or (handler[i].callback == callback) then
        remove(handler, i)
      end
    end
  end
  return instance
end

-- Calls all callbacks registered with an associated message
--  Example: object:trigger("signal")
--
-- As a shorthand, the message behaves as a callable method
-- on the object
--   Example: object:signal()
function observer.trigger(instance, message, ...)
  local handler = instance[message]
  if handler ~= nil then
    return handler(instance, ...)
  end
  return instance
end

-- Adds on, off, and trigger to an object
function observer.mixin(object)
  object.on = observer.on
  object.off = observer.off
  object.trigger = observer.trigger
  return object
end

-- Returns a new object with on, off, and trigger available
function observer.new()
  return setmetatable({}, observer_mt)
end

return observer

