local util = require("utils.util")


gg.BIG_ENDIAN    = "r"
gg.LITTLE_ENDIAN = "h"


--- Get the value of a memory address.
gg.getValue = function(address, flags)
  local status, values = pcall(gg.getValues, { { address = address, flags = flags } })
  if not status then return nil end

  return values[1]
end


--- Get the value of a memory address as a hex string.
gg.getHex = function(address, bitSize)
  local value = gg.getValue(address, gg.TYPE_BYTE)
  if not value then return nil end

  bitSize = bitSize or 8

  local hex = ""
  for i = 1, bitSize do
    local v = value.value % 256
    if v < 0 then v = v + 256 end
    hex = hex .. string.format("%02X", v)
    value = gg.getValue(value.address + 1, gg.TYPE_BYTE)
  end

  return hex
end





--- Keep the script alive. (Main loop)
gg.keepAlive = function(fn)
  while true do
    if gg.isVisible() then
      gg.setVisible(false)
      fn()
    end
    gg.sleep(100)
  end
end

--- Keep the script alive with a UI button. (Main loop)
gg.keepAliveUiButton = function(fn)
  gg.showUiButton()
  while true do
    if gg.isClickedUiButton() then fn() end
    gg.sleep(100)
  end
end

gg.toggleValue = function(value)
  if value.processPause then gg.processPause() end

  if util.isHex(value.patch:gsub("r", "")) then
    local hex = value.state and value.original or value.patch
    gg.patchHex(value.address, hex, value.freeze)
  else
    local opcode = value.state and value.original or value.patch
    gg.setValues({ { address = value.address, flags = value.flags, value = opcode } })
  end

  if gg.isProcessPaused() then gg.processResume() end
  value.state = not value.state
end

--- Set the hex value of a memory address.
gg.patchHex = function(address, hex, freeze, processPause)
  gg.sleep(100)

  local values = {}

  for i = 1, #hex - 1, 2 do
    table.insert(values, {
      address = address,
      flags   = gg.TYPE_BYTE,
      freeze  = freeze,
      value   = string.sub(hex, i, i + 1) .. hex:sub( -1)
    })
    address = address + 1
  end

  if processPause then gg.processPause() end
  if freeze then gg.addListItems(values) else gg.setValues(values) end
  if gg.isProcessPaused() then gg.processResume() end
end

return gg
