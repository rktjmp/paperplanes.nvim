local function provide(content, metadata, opts, on_complete)
  local curl = require("paperplanes.curl")
  local args = {"--data-binary", content, "https://paste.rs"}
  local resp_handler
  local function _1_(response, status)
    if (status == 201) then
      return on_complete(response)
    elseif true then
      local _ = status
      return on_complete(nil, response)
    else
      return nil
    end
  end
  resp_handler = _1_
  return curl(args, resp_handler)
end
return provide