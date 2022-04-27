 local _local_1_ = require("paperplanes.fn") local reduce = _local_1_["reduce"] local list_put = _local_1_["list-put"] local list_append = _local_1_["list-append"] local map_put = _local_1_["map-put"]

 local function provide(content, metadata, opts)



 local defaults = {format = "default", content = content, filename = metadata.filename} local args


 local function _2_(_241, _242, _243) return map_put(_243, _241, _242) end
 local function _3_(_241, _242, _243) return list_append(_243, {"-F", (_241 .. "=" .. _242)}) end args = list_put(reduce(reduce(opts, defaults, _2_), {}, _3_), "https://dpaste.org/api/") local resp_handler

 local function _4_(response, status)
 local _5_ = status if (_5_ == 200) then
 return string.match(response, "\"(.*)\"") elseif true then local _ = _5_
 return nil, response else return nil end end resp_handler = _4_
 return args, resp_handler end

 return provide