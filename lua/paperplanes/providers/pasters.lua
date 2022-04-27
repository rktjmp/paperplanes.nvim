 local function provide(content, metadata, opts)
 local args = {"--data-binary", content, "https://paste.rs"} local resp_handler
 local function _1_(response, status)
 local _2_ = status if (_2_ == 201) then

 return string.match(response, "^(https?://.*)\n") elseif true then local _ = _2_
 return nil, response else return nil end end resp_handler = _1_
 return args, resp_handler end

 return provide