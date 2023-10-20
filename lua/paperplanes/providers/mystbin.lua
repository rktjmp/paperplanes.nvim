local fmt = string.format
local function body(content, filename)
  return vim.json.encode({files = {{content = content, filename = filename}}})
end
local function provide(content, metadata, opts, on_complete)
  local curl = require("paperplanes.curl")
  local args = {"--request", "PUT", "--header", "Content-Type: application/json", "--data", body(content, ((string.len(metadata.filename) and metadata.filename) or "untitled")), "https://api.mystb.in/paste"}
  local resp_handler
  local function _1_(response, status)
    if (status == 200) then
      local response0 = vim.json.decode(response)
      local url = fmt("https://mystb.in/%s/", response0.id)
      return on_complete(url)
    elseif (status == 429) then
      return on_complete(nil, "ratelimit reached, please try again later")
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  resp_handler = _1_
  return curl(args, resp_handler)
end
return provide