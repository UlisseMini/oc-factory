local shell = require('shell')

local get = function(...)
  for _, file in ipairs({...}) do
    shell.run('wget -f https://raw.githubusercontent.com/UlisseMini/oc-factory/master/' .. file)
  end
end

get({'coords.lua', 'factory.lua', 'modules/test.lua', 'quarry.lua'})
