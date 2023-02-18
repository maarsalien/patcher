local gg        = require "lib.gg"
local table     = require "lib.table"
local dconfig   = require "configs.config"
local util      = require "utils.util"

local Patcher   = {}
Patcher.__index = Patcher

--- Create a new Patcher instance.
function Patcher.new(config)
  local self  = setmetatable({}, Patcher)
  self.values = table.new()
  self.config = setmetatable(config, { __index = dconfig })
  return self
end

--- Get the base address of the executable memory.
function Patcher.getBaseAddr(filter)
  if not filter then
    util.error("No filter for the executable memory was provided")
  end

  local ranges = gg.getRangesList(filter)
  if #ranges == 0 then goto notfound end

  for _, v in ipairs(ranges) do
    if v.state == "Xa" then return v.start end
  end

  ::notfound::
  util.error(string.format("Could not find executable memory for: %s", filter))
end

--- Add a value to the patcher.
function Patcher:add(value)
  local tValue = gg.getValue(value.address, gg.TYPE_QWORD)

  if not tValue then
    util.error(string.format("Could not find address: %s for value: %s", value.address, value.name))
  end

  value          = setmetatable(value, { __index = tValue })
  value.state    = value.state or false
  value.patch    = value.patch:gsub(" ", "")
  value.original = gg.getHex(value.address, #value.patch:sub(1, -2)) .. gg.BIG_ENDIAN

  table.insert(self.values, value)
end

function Patcher:run()
  local debug

  if #self.values == 0 then
    gg.alert("No values to run")
    return
  end

  local function main()
    gg.sleep(100)

    debug = false

    local menuItem = self.values:map(function(v)
      return util.concat(v.state and self.config.on or self.config.off, " ", v.name)
    end)
    menuItem[#menuItem + 1] = "Exit"

    local ch = gg.choice(menuItem, 0, self.config.title)

    if not ch then return end
    if ch == #menuItem then util.cleanExit() end

    local value = self.values[ch]

    if value.processPause then
      gg.processPause()
    end

    if value.state then
      gg.setHex(value.address, value.original, value.freeze)
    else
      gg.setHex(value.address, value.patch, value.freeze)
    end

    if gg.isProcessPaused() then
      gg.processResume()
    end

    value.state = not value.state
    gg.toast(util.concat(value.state and self.config.on or self.config.off, " ", value.name))
  end

  -- Main loop (Keeps the script running)
  while true do
    if gg.isVisible() then
      debug = true
      gg.setVisible(false)
    end
    if debug then main() end
  end
end

return Patcher