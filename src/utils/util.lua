local util = {}

--- Alert the user and exit the script.
util.error = function(msg)
  gg.alert(msg, "Exit")
  error(msg, 0)
end

--- Convert a decimal number to a hex string.
util.toHex = function(n, pre)
  return string.format("%s%X", pre and "0x" or "", n)
end

--- Check if a string is a hex string.
util.isHex = function(str)
  return string.match(str:gsub(" ", ""), "^%x+$") ~= nil
end

--- Concatenate multiple strings.
util.concat = function(...)
  local str = ""
  for _, v in ipairs({ ... }) do
    str = str .. v
  end
  return str
end

--- Cleanly exit the script.
util.cleanExit = function()
  gg.setVisible(false)
  gg.clearList()
  gg.toast("Exiting...")
  os.exit()
end

return util
