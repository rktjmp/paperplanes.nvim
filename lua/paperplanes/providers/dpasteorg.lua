 local _local_1_ = require("paperplanes.fn") local reduce = _local_1_["reduce"] local list_put = _local_1_["list-put"] local list_append = _local_1_["list-append"] local map_put = _local_1_["map-put"]
 local fmt = string.format

 local function provide(content, metadata, opts, on_complete)



 local curl = require("paperplanes.curl")
 local temp_filename = vim.fn.tempname()
 local defaults = {format = "default", filename = metadata.filename} local args

 local function _2_(_241, _242, _243) return map_put(_243, _241, _242) end
 local function _3_(_241, _242, _243) return list_append(_243, {"--data-urlencode", fmt("%s=%s", _241, _242)}) end args = list_put(list_append(reduce(reduce(opts, defaults, _2_), {}, _3_), {"--data-urlencode", fmt("content@%s", temp_filename)}), "https://dpaste.org/api/") local resp_handler


 local function _4_(response, status)
 vim.loop.fs_unlink(temp_filename)
 local _5_ = status if (_5_ == 200) then
 return on_complete(string.match(response, "\"(.*)\"")) elseif true then local _ = _5_
 return on_complete(nil, response) else return nil end end resp_handler = _4_
 do local outfile = io.open(temp_filename, "w") local function close_handlers_8_auto(ok_9_auto, ...) outfile:close() if ok_9_auto then return ... else return error(..., 0) end end local function _8_() return outfile:write(content) end close_handlers_8_auto(_G.xpcall(_8_, (package.loaded.fennel or debug).traceback)) end

 return curl(args, resp_handler) end

 return provide