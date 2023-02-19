local gg        = require "lib.gg"
local table     = require "lib.table"
local dconfig   = require "configs.config"
local util      = require "utils.util"

local Patcher   = {}
Patcher.__index = Patcher


local VERSION_CODE = 210
local VERSION_NAME = "2.1.0"


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

--- Check if the version of the Patcher is compatible with the script.
function Patcher.require(version)
  if not version then
    util.error("No version was provided")
  end

  if version > VERSION_CODE then
    util.error(string.format(
      "The version of the Patcher is not compatible with the script. Script version: %s, Patcher version: %s", version,
      VERSION_CODE))
  end
end

--- Patch a memory address with a hex string.
function Patcher.patch(address, hex, freeze, processPause)
  if processPause then gg.processPause() end
  if not address then util.error("No address was provided") end
  if not hex then util.error("No hex was provided") end
  gg.setHex(address, hex:gsub(" ", ""), freeze)
  if gg.isProcessPaused() then gg.processResume() end
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

    table.insert(menuItems, 1, "Toggle All")
    table.insert(menuItems, 2, "Enable All")
    table.insert(menuItems, 3, "Disable All")
    table.insert(menuItems, "Exit")

    local ch = gg.choice(menuItems, 0, self.config.title)

    if not ch then return end

    -- Toggle all values
    if ch == 1 then
      self.values:forEach(function(v) gg.toggleValue(v) end)
      return gg.toast("All values toggled")
    end

    --- Enable all values
    if ch == 2 then
      self.values:forEach(function(v) if not v.state then gg.toggleValue(v) end end)
      return gg.toast("All values enabled")
    end

    --- Disable all values
    if ch == 3 then
      self.values:forEach(function(v) if v.state then gg.toggleValue(v) end end)
      return gg.toast("All values disabled")
    end

    if ch == #menuItems then util.cleanExit() end

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
