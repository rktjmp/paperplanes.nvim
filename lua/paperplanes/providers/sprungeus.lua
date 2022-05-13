 local fmt = string.format

 local function provide(content, metadata, opts, on_complete)
 assert((true == opts.insecure), "sprunge.us support is disabled as it does not support https. You must set the provider option insecure = true")

 local curl = require("paperplanes.curl")
 local temp_filename = vim.fn.tempname()
 local args = {"--data-urlencode", fmt("sprunge@%s", temp_filename), "http://sprunge.us"} local resp_handler

 local function _1_(response, status)
 vim.loop.fs_unlink(temp_filename)
 local _2_ = status if (_2_ == 200) then

 return on_complete(string.match(response, "^(http://.*)\n")) elseif true then local _ = _2_
 return on_complete(nil, response) else return nil end end resp_handler = _1_
 do local outfile = io.open(temp_filename, "w") local function close_handlers_8_auto(ok_9_auto, ...) outfile:close() if ok_9_auto then return ... else return error(..., 0) end end local function _5_() return outfile:write(content) end close_handlers_8_auto(_G.xpcall(_5_, (package.loaded.fennel or debug).traceback)) end

 return curl(args, resp_handler) end

 return provide