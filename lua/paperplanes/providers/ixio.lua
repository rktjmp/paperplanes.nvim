 local _local_1_ = require("paperplanes.fn") local reduce = _local_1_["reduce"] local list_put = _local_1_["list-put"] local list_append = _local_1_["list-append"] local map_put = _local_1_["map-put"]

 local function provide(content, metadata, opts)
 assert((true == opts.insecure), "ix.io support is disabled as it does not support https. You must set the provider option insecure = true")

 local defaults = {["f:1"] = content, ["name:1"] = metadata.filename, ["ext:1"] = metadata.extension} local args



 local function _2_(_241) local _3_ = _241 map_put(_3_, "insecure", nil) return _3_ end local function _4_(_241, _242, _243) return map_put(_243, _241, _242) end
 local function _5_(_241, _242, _243) return list_append(_243, {"-F", (_241 .. "=" .. _242)}) end args = list_put(reduce(_2_(reduce(opts, defaults, _4_)), {}, _5_), "http://ix.io/") local resp_handler

 local function _6_(response, status)
 local _7_ = status if (_7_ == 200) then

 return string.match(response, "(http://.*)\n") elseif true then local _ = _7_
 return nil, response else return nil end end resp_handler = _6_
 return args, resp_handler end

 return provide