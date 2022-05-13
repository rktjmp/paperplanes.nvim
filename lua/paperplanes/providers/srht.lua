 local fmt = string.format

 local function provide(content, metadata, opts, on_complete)
 assert(opts.token, "You must set provider_options.token to your sr.ht token")
 local curl = require("paperplanes.curl")
 local auth_header = fmt("Authorization:token %s", opts.token)
 local encoded = vim.json.encode({visibility = (opts.visibility or "unlisted"), files = {{filename = metadata.filename, contents = content}}})



 local args = {"--header", auth_header, "--header", "Content-Type:application/json", "https://paste.sr.ht/api/pastes", "--data-binary", encoded} local resp_handler



 local function _1_(response, status)
 local _2_ = status if (_2_ == 201) then
 local response0 = vim.json.decode(response)
 local url = fmt("https://paste.sr.ht/%s/%s", response0.user.canonical_name, response0.sha)


 return on_complete(url) elseif true then local _ = _2_
 return on_complete(nil, response) else return nil end end resp_handler = _1_
 return curl(args, resp_handler) end

 return provide