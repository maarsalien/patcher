gg.BIG_ENDIAN    = "r"
gg.LITTLE_ENDIAN = "h"


--- Get the value of a memory address.
gg.getValue = function(address, flags)
  local status, values = pcall(gg.getValues, { { address = address, flags = flags } })
  if not status then return nil end

  return values[1]
end


--- Get the value of a memory address as a hex string.
gg.getHex = function(address, bitSize, bigEndian)
  local value = gg.getValue(address, gg.TYPE_BYTE)
  if not value then return nil end

  local hex = ""
  for i = 1, bitSize do
    local v = value.value % 256
    if v < 0 then v = v + 256 end
    hex = hex .. string.format("%02X", v)
    value = gg.getValue(value.address + 1, gg.TYPE_BYTE)
  end

  return bigEndian and string.reverse(hex) or hex
end


--- Set the hex value of a memory address.
gg.setHex = function(address, hex, freeze)
  local values = {}

  for i = 1, #hex - 1, 2 do
    table.insert(values, {
      address = address,
      flags   = gg.TYPE_BYTE,
      value   = string.sub(hex, i, i + 1) .. hex:sub( -1)
    })
    address = address + 1
  end

  if freeze then
    for i = 1, #values do
      values[i].freeze = true
    end
    gg.addListItems(values)
    return
  end

  gg.setValues(values)
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
    if gg.isClickedUiButton() then
      fn()
    end
    gg.sleep(100)
  end
end

gg.toggleValue = function(value)
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
end

return gg
