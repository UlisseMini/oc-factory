-- Runtime for factory program, modules will be written in ./factory-modules.lua

local computer   = require('computer')
local event      = require('event')
local filesystem = require('filesystem')
local t          = require('coords')
local printf     = function(s, ...) return print(s:format(...)) end

factory = {
  tasks = {}
}

-- Lower level version of register, for raw events.
-- The caller is responsible for calling event.push('task', name)
-- when they want their task executed.
function factory:registerEvent(task, name)
  if self.tasks[name] ~= nil then
    error('a task with the name ' .. name .. ' already exists')
  end

  self.tasks[name] = task
end

-- Registers a task, This calls event.timer can pushes an event for the task
-- every 'interval' seconds.
function factory:register(task, name, options)
  assert(
    type(task)             == 'function' and
    type(options.interval) == 'number'   and
    type(name)             == 'string'   and
    type(options.level)    == 'number'   and
    type(options.ori)      == 'string')

  self:registerEvent(task, name)

  -- NOTE: Timer cannot be canceled once started.
  -- NOTE: We cannot send functions over event.push, thats why we have self.tasks
  event.timer(options.interval, function() event.push('task', name) end, math.huge)
end

local function readInt(msg)
  io.write(msg)
  local s = io.read()
  return assert(tonumber(s), 'Invalid number "' .. s .. '"')
end

-- same as t.moveTo but errors if x ~= 0 or z ~= 0 (aka if not in shaft)
function factory:moveTo(w)
  assert(t.c.x == 0 and t.c.z == 0, 't.x and t.z must be equal to zero')
  t.moveTo(w)
end

function factory:refuel()
  self:moveTo(self.charger)
  -- Not doing energy == maxEnergy because we might consume right after charg and waste time
  repeat os.sleep(10) until (computer.energy() / computer.maxEnergy()) > 0.99
end

function factory:init()
  -- Get our aboslute coordanites
  print('To work correctly I need my absolute Y coordanite and my orientation.')

  t.y = readInt('y: ')
  io.write('orientation (north, east, south, west): ')
  local ori = io.read()
  assert(t.oris[ori], 'orientation must be one of (north, east, south, west)')
  t.ori = t.oris[ori]

  print('Are you absolutly sure you put in the correct coordanites?')
  print('Are you absolutly sure you placed the robot over next to the charger and over the shaft?')
  io.write('(y/n) ')
  local s = io.read()
  if s ~= 'yes' and s ~= 'y' then
    print('Exiting.')
    os.exit(0)
  end

  self.charger = t.dump()
end

function factory:run()
  while true do
    -- Check fuel, if we have less then 20% remaining refuel
    if (computer.energy() / computer.maxEnergy()) < 0.2 then
      self:refuel()
    end

    local _, name = event.pull('task')
    print('Running task ' .. name)

    local energy_before = computer.energy()
    self.tasks[name](t)
    local energy_after = computer.energy()

    local used_percent = ((energy_before - energy_after) / computer.maxEnergy()) * 100
    printf('Task %s completed used %d%% percent of our energy', name, used_percent)
    assert(t.c.x == 0 and t.c.z == 0,
      ('x(%d) and z(%d) must be equal to zero after task finishes'):format(t.c.x, t.c.z))
    if used_percent > 20 then
      error('Used more then 20% of our energy, we could have run out')
    end
  end
end

for mod_name in filesystem.list('/home/modules') do
  local task, options = dofile('/home/modules' .. mod_name)

  -- Remove extension from filename
  local name = mod_name:gsub('%..*$', '')

  factory:register(task, name, options)
end

factory:init()
factory:run()
