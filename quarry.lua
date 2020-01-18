-- FastQuarry

local r         = require('robot')
local computer  = require('computer')
local component = require('component')

-- our current depth, 0 is our starting point.
local depth = 0

-- return to the surface then os.exit(code)
local surface = function(code)
  for i=0,depth do
    while r.detectUp() do r.swingUp() end
    assert(r.up())
    depth = depth - 1
  end
  os.exit(code)
end

local lowEnergy = function()
  -- if we have a generator try to consume fuel to keep going
  if component.generator then
    for i=1,r.inventorySize() do
      r.select(i)
      local ok, err = component.generator.insert(r.count())

      -- return if we're already charging as much as possible.
      if err == 'queue is full' then return end
    end

    -- if we're charging then we're fine
    if component.generator.count() > 0 then return end
  end

  -- must not have charged! return to the surface.
  print("Low energy, returning to surface.")
  surface(1)
end

-- go forward n times, breaking anything above below and infront of him
-- if n is nil then go forward once.
-- TODO: Fix problem when reaching bedrock.
local forward = function(n)
  for i=1,n or 1 do
    while r.detect()     and r.swing()     do end
    while r.detectUp()   and r.swingUp()   do end
    while r.detectDown() and r.swingDown() do end

    while not r.forward() do
      while r.detect() do r.swing() end
    end
  end
end

local turn = function(turnFn)
  turnFn()
  forward()
  turnFn()
end

local quarry_layer = function(length, width)
  for i=1,width-1 do
    -- dig out this line
    forward(length-1)

    -- alternate between turning right and left
    if i % 2 == 0
      then turn(r.turnLeft)  -- second iteration
      else turn(r.turnRight) -- first iteration
    end
  end

  -- on the last line don't turn to a new line
  forward(length-1)

  -- go back to the quarry_start
  if width % 2 == 0 then
    r.turnRight()
    forward(width-1)
    r.turnRight()
  else
    r.turnLeft()
    forward(width-1)
    r.turnLeft()
    forward(length-1)
    r.turnLeft()
    r.turnLeft()
  end

  if computer.energy() < 200 then
    lowEnergy()
  end
end

-- do a quarry, this is the main method
local quarry = function(length, width)
  while true do
    quarry_layer(length, width)

    -- move down three blocks
    for i=1,3 do
      while r.detectDown() and r.swingDown() do end
      if not r.down() then
        print('Bedrock!')
        break
      end
      depth = depth + 1
    end
  end

  -- Go back to the surface
  surface(0)
end

local args = {...}
if #args ~= 2 then
  print('Usage: quarry <length> <width>')
  os.exit(1)
end

local length = assert(tonumber(args[1]), 'length must be a number')
local width  = assert(tonumber(args[2]), 'width must be a number')

quarry(length, width)
