
# Patcher 

Patcher is a gameguardian library for patching memory address, it provides a simple interface and handle on/off state of patching.

## Installation

Download the latest version of patcher from [here]() and add it to your project.

You can also load the latest version of Patcher from the [cdn][cdn] using the following code.

```lua
local _, Patcher = pcall(load(gg.makeRequest("https://pastebin.com/raw/wz1sfmWF").content))
```

## Usage

Make sure to place the `Patcher.lua` file in the same directory as your script.

```lua
local Patcher = require("Patcher")

local il2cpp    = Patcher.getBaseAddr("libil2cpp.so")
local libunity  = Patcher.getBaseAddr("libunity.so")

local p = Patcher.new({
  title = "Custom Title",
})

p:add({
  name    = "Damage Multiplier",
  address = il2cpp + 0x18643A8,
  patch   = "01 04 A0 E3 1E FF 2F E1r",
})

p:add({
  name    = "HP Multiplier",
  address = libunity + 0x1864F88,
  patch   = "01 04 A0 E3 1E FF 2F E1r"
})

p:run()

```

## Class Members

**Note**: Arguments and table field marked with `?` are optional.

`Patcher.getBaseAddr(filter)`

Get the base address of a library.

**Parameters**

- `filter` (string) - The library name to filter. *[see](https://gameguardian.net/help/classgg.html#a8bb9745b0b7ae43f8a228a373031b1ed)*
- `return` (number) - The base address of the library, or nil if the library is not found.

Example:

```lua
local Patcher = require("Patcher")

local ue4       = Patcher.getBaseAddr("libUE4.so")
local libunity  = Patcher.getBaseAddr("libunity.so")
local il2cpp    = Patcher.getBaseAddr("libil2cpp.so")
```

<br>
<br>

`Patcher.new(config)`

Create a new Patcher instance.

**Parameters**

- `config` (table) - The configuration table.
  - `?title` (string) - The title to show in the menu.
  - `?on` (string) - The text to display when the patch is enabled.
  - `?off` (string) - The text to display when the patch is disabled.

- `return` (Patcher) - The Patcher instance.

Example:

```lua
local Patcher = require("Patcher")

local p = Patcher.new({
  title = "Custom Title",
})
```

<br>
<br>

`Patcher:add(value)`

Add a new value to the patcher instance.


**Parameters**

- `value` (table) - The value table.
  - `name` (string) - The name of the value to display in the menu.
  - `address` (number) - The address of the value.
  - `patch` (string) - The patch to apply to the value when enabled.
  - `?freeze` (boolean) - Freeze the value (default: false)
  - `?state` (boolean) - The initial state of the value (default: false).
  - `?processPause` (boolean) - Pause the process before applying the patch and resume it after applying the patch (default: false). *[see](https://gameguardian.net/help/classgg.html#a14e502f895d2e989ebb31dc101f1b325)*



Example:

```lua
local Patcher = require("Patcher")

local p = Patcher.new({
  title = "Custom Title",
})

p:add({
  name    = "Damage Multiplier",
  address = 0x18643A8,
  patch   = "01 04 A0 E3 1E FF 2F E1r",
})
```

**Note**: The patch field value must be a valid hexadecimal string ending with `r` or `h` to indicate the endianness of the value. (whitespace is ignored)

**Example**: `01 04 A0 E3 1E FF 2F E1r`

**Example**: `01 04 A0 E3 1E FF 2F E1h`

**Note**: Patcher support patching for hexadecimals values longer than 8 bytes. (whitespace is ignored)

**Example**: `F0 48 2D E9 10 B0 8D E2 08 D0 4D E2 00 40 A0 E1r`


<br>
<br>

`Patcher:run()`

Run the patcher instance.

Example:

```lua
local Patcher = require("Patcher")

local p = Patcher.new({
  title = "Custom Title",
})

p:add({
  name    = "Damage Multiplier",
  address = 0x18643A8,
  patch   = "01 04 A0 E3 1E FF 2F E1r",
})

p:run()
```


## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. Please make sure to update tests as appropriate and follow the [Code of Conduct]( CODE_OF_CONDUCT.md ).

To build the project you will need to have [nodejs](https://nodejs.org/en/) installed, or you can use your own build script for building the project.

- Fork the repository
- Clone the repository
- Make your changes
- Commit and push your changes
- Create a pull request

**Steps to build the project**

- Run `npm install` to install the dependencies.
- Run `npm run build` to build the project.

## License

[MIT](https://choosealicense.com/licenses/mit/)

This project is not affiliated with [GameGuardian][gg] or any of its developers in any way and is not endorsed by them in any way or form whatsoever and is not intended to be used for any illegal purposes whatsoever and is intended for educational purposes only and the author of this project is not responsible for any misuse of this project or any damage caused by this project in any way or form whatsoever.

## Credits

- [GameGuardian][gg] - For the awesome GameGuardian app.
- [BadCase](https://gameguardian.net/forum/profile/698974-badcase/) - For recommendation and testing.
- [Lover1500](https://gameguardian.net/forum/profile/1129048-lover1500/) - For recommendation and testing.
- [CmP](https://gameguardian.net/forum/profile/745088-cmp/) - For recommendation and testing.
- [mikacyber](https://gameguardian.net/forum/profile/496269-mikacyber/) - For recommendation and testing.

## Contact

- [Telegram](https://t.me/maarsalien)
- [Discord](https:/discordapp.com/users/629189898947264512)
- [GameGuardian](https://gameguardian.net/forum/profile/1138303-maars/)


<!-- links -->
[gg]: https://gameguardian.net/
[cdn]: https://pastebin.com/raw/wz1sfmWF