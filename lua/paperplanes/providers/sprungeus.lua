 local function provide(content, metadata, opts)
 assert((true == opts.insecure), "sprunge.us support is disabled as it does not support https. You must set the provider option insecure = true")

 local args = {"-F", ("sprunge=" .. content), "http://sprunge.us"} local resp_handler
 local function _1_(response, status)
 local _2_ = status if (_2_ == 200) then

 return string.match(response, "^(http://.*)\n") elseif true then local _ = _2_
 return nil, response else return nil end end resp_handler = _1_
 return args, resp_handler end

 return provide