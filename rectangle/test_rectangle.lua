
local Rectangle = require 'rectangle'

local unittests = {

  ["As Class"] = function()
    local rect = Rectangle.new()
    assert(rect)
    assert(rect._x == 0)
    assert(rect._y == 0)
    assert(rect._w == 0)
    assert(rect._h == 0)
  end,

  ["As Mixin"] = function()
    local rect = {}
    Rectangle.mixin(rect)
    assert(rect._x == 0)
    assert(rect._y == 0)
    assert(rect._w == 0)
    assert(rect._h == 0)
    Rectangle.init(rect, 5, 10, 15, 20)
    assert(rect._x == 5)
    assert(rect._y == 10)
    assert(rect._w == 15)
    assert(rect._h == 20)
  end,

  ["Getters"] = function()
    local rect = Rectangle.new(5, 10, 15, 20)
    assert(rect:left() == 5)
    assert(rect:right() == 20)
    assert(rect:top() == 10)
    assert(rect:bottom() == 30)
    assert(rect:width() == 15)
    assert(rect:height() == 20)
    local cx, cy = rect:center()
    assert(cx > 12.49 and cx < 12.51 ) -- close enough
    assert(cy > 19.99 and cy < 20.01 )
    -- just for code coverage
    rect:size()
    rect:topLeft()
    rect:topRight()
    rect:topCenter()
    rect:leftCenter()
    rect:rightCenter()
    rect:bottomLeft()
    rect:bottomCenter()
    rect:bottomRight()
  end,

  ["Setters"] = function()
    local rect = Rectangle.new()
    -- code coverage
    rect:left(5)
    rect:top(10)
    rect:width(15)
    rect:height(20)
    rect:right(20)
    rect:bottom(30)
    rect:size(15, 20)
    rect:topLeft(1, 2)
    rect:topRight(3, 4)
    rect:topCenter(5, 6)
    rect:leftCenter(7, 8)
    rect:center(9, 10)
    rect:rightCenter(11, 12)
    rect:bottomLeft(13, 14)
    rect:bottomCenter(15, 16)
    rect:bottomRight(17, 18)
  end,

  ["Collisions"] = function()
    local first = Rectangle.new(10, 10, 10, 10)
    local second = Rectangle.new(15, 15, 10, 10)
    local third = Rectangle.new(50, 10, 50, 10)

    assert(first:overlapsRect(second))
    assert(not first:overlapsRect(third))
    assert(first:overlapsRect(12, 12, 2, 2))
    assert(first:containsPoint(15, 15))
    assert(not third:containsPoint(15, 15))
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

