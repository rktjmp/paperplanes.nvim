 local _local_1_ = require("paperplanes.fn") local reduce = _local_1_["reduce"] local list_put = _local_1_["list-put"] local list_append = _local_1_["list-append"] local map_put = _local_1_["map-put"]

 local function provide(content, _metadata, opts, on_complete)



 local curl = require("paperplanes.curl")
 local filename = vim.fn.tempname()

 local args = {"-F", ("file=@" .. filename), "https://0x0.st/"} local response_handler
 local function _2_(response, status)
 vim.loop.fs_unlink(filename)
 local _3_ = status if (_3_ == 200) then

 return on_complete(string.match(response, "(https://.*)\n")) elseif true then local _ = _3_
 return on_complete(nil, response) else return nil end end response_handler = _2_
 do local outfile = io.open(filename, "w") local function close_handlers_8_auto(ok_9_auto, ...) outfile:close() if ok_9_auto then


 return ... else return error(..., 0) end end local function _6_() return outfile:write(content) end close_handlers_8_auto(_G.xpcall(_6_, (package.loaded.fennel or debug).traceback)) end return curl(args, response_handler) end
 return provide