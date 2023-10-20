local function list_put(sequence, val, _3fpos)
  if _3fpos then
    table.insert(sequence, _3fpos, val)
    return sequence
  else
    table.insert(sequence, val)
    return sequence
  end
end
local function list_append(sequence, seq)
  local s = sequence
  for _, val in ipairs(seq) do
    table.insert(s, val)
    s = s
  end
  return s
end
local function map_put(map, key, val)
  map[key] = val
  return map
end
local function reduce(enum, into, func)
  local acc = into
  for key, val in pairs(enum) do
    acc = func(key, val, acc)
  end
  return acc
end
local function ireduce(enum, into, func)
  local acc = into
  for idx, val in ipairs(enum) do
    acc = func(idx, val, acc)
  end
  return acc
end
return {ireduce = ireduce, reduce = reduce, ["map-put"] = map_put, ["list-put"] = list_put, ["list-append"] = list_append}