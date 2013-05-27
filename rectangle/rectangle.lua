-- Rectangle
-- See the included License file for copyright information.

-- Use it as a Class with .new
-- Use it as a Mixin/Component with .mixin
-- Use it on an instance with .init

-- The API for these functions is a "fluent" one, meaning
-- that each function is both a setter and a getter.
-- For instance, setting the top left coordinate:
--   rect:topLeft(10, 15)
-- And retrieving the topLeft coordinate:
--   x, y = rect:topLeft()

-- Each setter returns the self object, for use in method chaining:
--   rect:top(10):left(15)

-- Getters are detected via a nil in the first parameter, so this
-- is a valid getter call:
--   x, y = rect:bottomRight(nil)

-- all inputs are validated with 'tonumber', so numeric strings are accepted.

-- assert isnt localized so assertions can be disabled in release-mode
-- redefine it as ` function(x) return x end `

local NUMBER_ASSERT = "assertion failed in rectangle: value isnt number"
local setmetatable, pairs, tonumber = setmetatable, pairs, tonumber
local Rect, MT, mixin, new, init

Rect = {
  _x = 0,
  _y = 0,
  _w = 0,
  _h = 0,
}

MT = { 
  __index = Rect
}

function Rect:left(x)
  if x == nil then return self._x end
  self._x = assert(tonumber(x), NUMBER_ASSERT)
  return self
end

function Rect:top(y)
  if y == nil then return self._y end
  self._y = assert(tonumber(y), NUMBER_ASSERT)
  return self
end

function Rect:right(x)
  if x == nil then return self._x + self._w end
  x = assert(tonumber(x), NUMBER_ASSERT)
  self._w = x - self._x 
  return self
end

function Rect:bottom(y)
  if y == nil then return self._y + self._h end
  y = assert(tonumber(y), NUMBER_ASSERT)
  self._h = y - self._y
  return self
end

function Rect:centerX(x)
  if x == nil then return self._x + (self._w * 0.5) end
  x = assert(tonumber(x), NUMBER_ASSERT)
  self._x = x - (self._w * 0.5)
  return self
end

function Rect:centerY(y)
  if y == nil then return self._y + (self._h * 0.5) end
  y = assert(tonumber(y), NUMBER_ASSERT)
  self._y = y - (self._h * 0.5)
  return self
end

function Rect:width(w)
  if w == nil then return self._w end
  self._w = assert(tonumber(w), NUMBER_ASSERT)
  return self
end

function Rect:height(h)
  if h == nil then return self._h end
  self._h = assert(tonumber(h), NUMBER_ASSERT)
  return self
end

function Rect:size(w, h)
  if w == nil then return self._w, self._h end
  return self:width(w):height(h)
end

function Rect:topLeft(x, y)
  if x == nil then return self._x, self._y end
  return self:left(x):top(y)
end

function Rect:topRight(x, y)
  if x == nil then return self:right(), self._y end
  return self:right(x):top(y)
end

function Rect:bottomLeft(x, y)
  if x == nil then return self._x, self:bottom() end
  return self:left(x):bottom(y)
end

function Rect:bottomRight(x, y)
  if x == nil then return self:right(), self:bottom() end
  return self:right(x):bottom(y)
end

function Rect:topCenter(x, y)
  if x == nil then return self:centerX(), self._y end
  return self:centerX(x):top(y)
end

function Rect:bottomCenter(x, y)
  if x == nil then return self:centerX(), self._y end
  return self:centerX(x):top(y)
end

function Rect:leftCenter(x, y)
  if x == nil then return self._x, self:centerY() end
  return self:left(x):centerY(y)
end

function Rect:rightCenter(x, y)
  if x == nil then return self:right(), self:centerY() end
  return self:right(x):centerY(y)
end

function Rect:center(x, y)
  if x == nil then return self:centerX(), self:centerY() end
  return self:centerX(x):centerY(y)
end

function Rect:values(x, y, w, h)
  if x == nil then return self._x, self._y, self._w, self._h end
  return self:x(x):y(y):width(w):height(h)
end

-- l, t, r, and b are the Left-Top coordinates, and the Right-Bottom coordinates
function Rect:bounds(l, t, r, b)
  if l == nil then return self._x, self._y, self:right(), self:bottom() end
  return self:left(l):top(y):right(r):bottom(b)
end

function Rect:move(dx, dy)
  self._x = self._x + assert(tonumber(dx), NUMBER_ASSERT)
  self._y = self._y + assert(tonumber(dy), NUMBER_ASSERT)
  return self
end

function Rect:containsPoint(x, y)
  x = assert(tonumber(x), NUMBER_ASSERT)
  y = assert(tonumber(y), NUMBER_ASSERT)
  local r, b = self:bottomRight()
  return (x >= self._x) and (x <= r) and (y >= self._y) and (y <= b)
end

function Rect:overlapsRect(xother, y, w, h)
  local al, at, ar, ab = self:bounds()
  local bl, bt, br, bb 
  if type(xother) == "table" then
    bl, bt, br, bb = xother:bounds()
  else
    bl = assert(tonumber(xother), NUMBER_ASSERT)
    bt = assert(tonumber(y), NUMBER_ASSERT)
    br = bl + assert(tonumber(w), NUMBER_ASSERT)
    bb = bt + assert(tonumber(h), NUMBER_ASSERT)
  end
  return not ((al >= br) or (bl >= ar) or (at >= bb) or (bt >= ab))
end

-- helpful aliases
Rect.x = Rect.left
Rect.y = Rect.top
Rect.at = Rect.topLeft
Rect.leftTop = Rect.topLeft
Rect.centerTop = Rect.topCenter
Rect.rightTop = Rect.topRight
Rect.centerLeft = Rect.leftCenter
Rect.centerRight = Rect.rightCenter
Rect.leftBottom = Rect.bottomLeft
Rect.centerBottom = Rect.bottomCenter
Rect.rightBottom = Rect.bottomRight

-- modifies an object to have all of the members of Rect added to it
-- Call this on a Class or Entity to add these features
-- remember to call init in the class's constructor
function mixin(obj)
  for k, v in pairs(Rect) do
    if obj[k] == nil then obj[k] = v end
  end
  return obj
end

-- creates an instantiated object of the Rect class
function new(x, y, w, h)
  local obj = setmetatable({}, MT)
  init(obj, x, y, w, h)
  return obj
end

-- call on instances that include the Rect class
function init(obj, x, y, w, h)
  if x then obj._x = assert(tonumber(x), NUMBER_ASSERT) end
  if y then obj._y = assert(tonumber(y), NUMBER_ASSERT) end
  if w then obj._w = assert(tonumber(w), NUMBER_ASSERT) end
  if h then obj._h = assert(tonumber(h), NUMBER_ASSERT) end
  return obj
end

return {
  new = new,
  mixin = mixin,
  init = init,
  Rect = Rect,
  metatable = MT,
}

