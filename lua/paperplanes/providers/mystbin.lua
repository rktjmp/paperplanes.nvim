local fmt = string.format
local function completions()
  return {create = {"expires=string", "password=string"}, delete = {}}
end
local function create(content, metadata, options, on_complete)
  local curl = require("paperplanes.curl")
  local payload = {password = options.password, expires = options.expires, files = {{content = content, filename = (metadata.filename or "paste.txt")}}}
  local args = {"--request", "POST", "--header", "Content-Type: application/json", "--data", vim.json.encode(payload)}
  local resp_handler
  local function _2_(_1_)
    local response = _1_["response"]
    local status = _1_["status"]
    local headers = _1_["headers"]
    if (status == 200) then
      local _let_3_ = vim.json.decode(response)
      local id = _let_3_["id"]
      local safety = _let_3_["safety"]
      local url = fmt("https://mystb.in/%s/", id)
      return on_complete(url, {safety = safety})
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  resp_handler = _2_
  return curl("https://mystb.in/api/paste", args, resp_handler)
end
local function delete(context, options, on_complete)
  local original_url = context[1]
  local _let_5_ = context[2]
  local safety = _let_5_["safety"]
  if (nil ~= safety) then
    local safety0 = safety
    local curl = require("paperplanes.curl")
    local url = fmt("https://mystb.in/api/security/delete/%s", safety0)
    local response_handler
    local function _7_(_6_)
      local response = _6_["response"]
      local status = _6_["status"]
      local headers = _6_["headers"]
      if (status == 200) then
        return on_complete(original_url, {})
      else
        local _ = status
        return on_complete(nil, response)
      end
    end
    response_handler = _7_
    return curl(url, {}, response_handler)
  elseif (safety == nil) then
    local msg = fmt("No token recorded for %s, unable to delete.", original_url)
    return on_complete(nil, msg)
  else
    return nil
  end
end
return {create = create, delete = delete, completions = completions}