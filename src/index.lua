local gg        = require "lib.gg"
local table     = require "lib.table"
local dconfig   = require "configs.config"
local util      = require "utils.util"

local Patcher   = {}
Patcher.__index = Patcher


local VERSION_CODE = 241
local VERSION_NAME = "2.4.1"


--- Create a new Patcher instance.
function Patcher.new(config)
  local self  = setmetatable({}, Patcher)
  self.values = table.new()
  self.config = setmetatable(config, { __index = dconfig })
  return self
end

--- Get the version of the Patcher.
function Patcher.getVersions()
  return VERSION_CODE, VERSION_NAME
end

function Patcher.getHex(address, bitSize)
  return gg.getHex(address, bitSize)
end

--- Patch a memory address with a hex string.
function Patcher.patchHex(address, hex, freeze, processPause)
  gg.patchHex(address, hex, freeze, processPause)
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
  value.original = gg.getHex(value.address, #value.patch:sub(1, -2) / 2) .. gg.BIG_ENDIAN

  table.insert(self.values, value)
end

--- Run the patcher.
function Patcher:run()
  if #self.values == 0 then
    gg.alert("No values to run")
    return
  end

  -- Patch all values on start if needed
  self.values:forEach(function(v)
    if v.patchOnStart then gg.toggleValue(v) end
  end)

  --- Main function for the patcher.
  local function main()
    --- Build the menu items string.
    local menuItems = self.values:map(function(v)
      return self.config.menuBuilder and self.config.menuBuilder(v, self.config) or
          util.concat(v.state and self.config.on or self.config.off, " ", v.name)
    end)

    table.insert(menuItems, "Actions Menu")

    local ch = gg.choice(menuItems, 0, self.config.title)

    if not ch then return end
    if ch == #menuItems then return util.actionMenu(self.values) end

    --- Toggle the selected value.
    local value = self.values[ch]
    gg.toggleValue(value)
    gg.toast(util.concat(value.state and self.config.on or self.config.off, " ", value.name))
  end

  --- Keep script alive and show UI button if needed.
  if self.config.showUiButton then gg.keepAliveUiButton(main) end
  gg.keepAlive(main)
end

return Patcher
