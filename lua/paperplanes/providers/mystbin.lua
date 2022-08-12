 local fmt = string.format

 local function body(content, filename)
 return vim.json.encode({files = {{content = content, filename = filename}}}) end





 local function provide(content, metadata, opts, on_complete)
 local curl = require("paperplanes.curl")
 local args = {"--request", "PUT", "--header", "Content-Type: application/json", "--data", body(content, ((string.len(metadata.filename) and metadata.filename) or "untitled")), "https://api.mystb.in/paste"} local resp_handler




 local function _1_(response, status)
 local _2_ = status if (_2_ == 200) then
 local response0 = vim.json.decode(response)
 local url = fmt("https://mystb.in/%s/", response0.id)
 return on_complete(url) elseif (_2_ == 429) then
 return on_complete(nil, "ratelimit reached, please try again later") elseif true then local _ = _2_
 return on_complete(nil, response) else return nil end end resp_handler = _1_
 return curl(args, resp_handler) end

 return provide