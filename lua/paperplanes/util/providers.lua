local function set_field(t, key, value)
  if (value and ("" ~= value)) then
    table.insert(t, "-F")
    table.insert(t, (key .. "=" .. value))
  else
  end
  return t
end
local function opts_to_fields(opts)
  local fields = {}
  for key, value in pairs(opts) do
    set_field(fields, key, value)
  end
  return fields
end
return {["set-field"] = set_field, ["opts-to-fields"] = opts_to_fields}