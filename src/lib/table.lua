-- create a new table
table.new = function()
  return setmetatable({}, { __index = table })
end

-- return a new table with the result of calling fn for each element of t
table.map = function(t, fn)
  local r = table.new()
  for k, v in pairs(t) do
    r[k] = fn(v, k)
  end
  return r
end

--- Run fn for each element of t
table.forEach = function(t, fn)
  for k, v in pairs(t) do
    fn(v, k)
  end
end

return table
