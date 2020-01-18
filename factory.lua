-- Runtime for factory program, modules will be written in ./factory-modules.lua

local computer  = require('computer')
local event     = require('event')

factory = {
  tasks = {}
}

-- Registers a task, This calls event.timer can pushes an event for the task
-- every 'interval' seconds.
function factory:register(task, interval, name)
  assert(
    type(task)     == 'function' and
    type(interval) == 'number'   and
    type(name)     == 'string')

  if self.tasks[name] ~= nil then
    error('a task with the name ' .. name .. ' already exists')
  end

  self.tasks[name] = task

  -- NOTE: Timer cannot be canceled once started.
  -- NOTE: We cannot send functions over event.push.
  event.timer(interval, function() event.push('task', name) end, math.huge)
end

function factory:run()
  while true do
    local _, name = event.pull('task')
    print('Running task ' .. name)
    self.tasks[name]()
  end
end

dofile('factory-modules.lua')
factory:run()
