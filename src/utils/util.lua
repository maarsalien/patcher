local util = {}

--- Perform selected action on all values.
util.actionMenu = function(values)
  gg.setVisible(true)

  local ch = gg.choice({
    "Toggle All",
    "Patch All",
    "Restore All",
    "Return to Main Menu"
  }, 0, "Actions Menu")
  if not ch or ch == 4 then return end

  if ch == 1 then
    values:forEach(function(v) gg.toggleValue(v) end)
    return gg.toast("All values toggled")
  end

  if ch == 2 then
    values:forEach(function(v) if not v.state then gg.toggleValue(v) end end)
    return gg.toast("All values patched")
  end

  if ch == 3 then
    values:forEach(function(v) if v.state then gg.toggleValue(v) end end)
    return gg.toast("All values restored")
  end
end


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
