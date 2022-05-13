 local _local_1_ = require("paperplanes.fn") local reduce = _local_1_["reduce"] local list_put = _local_1_["list-put"] local list_append = _local_1_["list-append"] local map_put = _local_1_["map-put"]
 local fmt = string.format

 local function provide(content, metadata, opts, on_complete)
 assert((true == opts.insecure), "ix.io support is disabled as it does not support https. You must set the provider option insecure = true")

 local curl = require("paperplanes.curl")
 local temp_filename = vim.fn.tempname()
 local defaults = {["name:1"] = metadata.filename, ["ext:1"] = metadata.extension} local args


 local function _2_(_241) local _3_ = _241 map_put(_3_, "insecure", nil) return _3_ end local function _4_(_241, _242, _243) return map_put(_243, _241, _242) end
 local function _5_(_241, _242, _243) return list_append(_243, {"--data-urlencode", fmt("%s=%s", _241, _242)}) end args = list_put(list_append(reduce(_2_(reduce(opts, defaults, _4_)), {}, _5_), {"--data-urlencode", fmt("f:1@%s", temp_filename)}), "http://ix.io/") local resp_handler


 local function _6_(response, status)
 vim.loop.fs_unlink(temp_filename)
 local _7_ = status if (_7_ == 200) then

 return on_complete(string.match(response, "(http://.*)\n")) elseif true then local _ = _7_
 return on_complete(nil, response) else return nil end end resp_handler = _6_
 do local outfile = io.open(temp_filename, "w") local function close_handlers_8_auto(ok_9_auto, ...) outfile:close() if ok_9_auto then return ... else return error(..., 0) end end local function _10_() return outfile:write(content) end close_handlers_8_auto(_G.xpcall(_10_, (package.loaded.fennel or debug).traceback)) end

 return curl(args, resp_handler) end

 return provide