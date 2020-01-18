factory:register(function()
  print('Task #1 (every 10 sec)')
end, 10, 'task 1')

factory:register(function()
  print('Task #2 (every 3 sec)')
end, 3, 'task 2')
