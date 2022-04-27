 local function list_put(sequence, val, _3fpos)

 if _3fpos then
 local _1_ = sequence table.insert(_1_, _3fpos, val) return _1_ else
 local _2_ = sequence table.insert(_2_, val) return _2_ end end

 local function list_append(sequence, seq)

 local s = sequence for _, val in ipairs(seq) do

 local _4_ = s table.insert(_4_, val) s = _4_ end return s end

 local function map_put(map, key, val)

 local _5_ = map _5_[key] = val return _5_ end

 local function reduce(enum, into, func)

 local acc = into for key, val in pairs(enum) do
 acc = func(key, val, acc) end return acc end

 local function ireduce(enum, into, func)

 local acc = into for idx, val in ipairs(enum) do
 acc = func(idx, val, acc) end return acc end
 return {ireduce = ireduce, reduce = reduce, ["map-put"] = map_put, ["list-put"] = list_put, ["list-append"] = list_append}