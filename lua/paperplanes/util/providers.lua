local function set_field(t, key, value)
  if (value and ("" ~= value)) then
    table.insert(t, "-F")
    table.insert(t, (key .. "=" .. value))
  else
  end
  return t
end
return {["set-field"] = set_field}