# Examples of how to use the Patcher library API

<br>

## Customise the menu appearance

```lua
local Patcher = require("Patcher")

local il2cpp = Patcher.getBaseAddr("libil2cpp.so")

local function toHex(n)
  return string.format("0x%08X", n)
end

local p = Patcher.new({
  title       = "Custom Title",
  on          = "[ ON ]",
  off         = "[ OFF ]",
  menuBuilder = function(value, config)
    local state = value.state and config.on or config.off
    return string.format(
      "%s \nname: %s \naddress: %s \noriginal: %s \npatch: %s\n",
      state, value.name, toHex(value.address), value.original, value.patch
    )
  end,
})

p:add({
  name    = "Damage Multiplier",
  address = il2cpp + 0x18643A8,
  patch   = "01 04 A0 E3 1E FF 2F E1r",
})

p:add({
  name    = "HP Multiplier",
  address = il2cpp + 0x1864F88,
  patch   = "01 04 A0 E3 1E FF 2F E1r",
})

p:run()
```



