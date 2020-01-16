-- Automatic tree farm, also converts log -> charcoal for fuel

local t = require('coords')

-- List of all the TREE for us to CONSUME
-- (relitive to start ofc)
-- x, y, z
local trees = {
  {0, 0, -1},
  {0, 0, -5},
  {0, 0, -9},

  {4, 0, -9},
  {4, 0, -5},
  {4, 0, -1},

  {8, 0, -1},
  {8, 0, -5},
  {8, 0, -9},
}

-- BUG: If there is ceiling touched by tree this'll keep going up till it ends
-- FIX: Find the opencomputers version of turtle.inspect
-- TODO: Replant tree
local log = function()
  while t.detectUp() do
    t.swingUp()
    t.up()
  end
  t.moveTo(t.c.x, 0, t.c.z)
end

while true do
  for i, tree in ipairs(trees) do
    print('Going to tree #' .. tostring(i))
    t.moveTo(table.unpack(tree))
  end

  t.moveTo(0,0,0,0)

  -- Assume a battary or something will charge us
end
