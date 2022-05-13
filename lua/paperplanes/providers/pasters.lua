 local function provide(content, metadata, opts, on_complete)
 local curl = require("paperplanes.curl")
 local args = {"--data-binary", content, "https://paste.rs"} local resp_handler
 local function _1_(response, status)
 local _2_ = status if (_2_ == 201) then

 return on_complete(string.match(response, "^(https?://.*)\n")) elseif true then local _ = _2_
 return on_complete(nil, response) else return nil end end resp_handler = _1_
 return curl(args, resp_handler) end

 return provide