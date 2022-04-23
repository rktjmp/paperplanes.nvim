local _local_1_ = require("paperplanes.util.providers")
local set_field = _local_1_["set-field"]
local function make(content_arg, meta)
  local args
  do
    local _2_ = {}
    set_field(_2_, "sprunge", content_arg)
    table.insert(_2_, "http://sprunge.us")
    args = _2_
  end
  local function after(response, status)
    local _3_ = status
    if (_3_ == 200) then
      return string.match(response, "^(http://.*)\n")
    elseif true then
      local _ = _3_
      return nil, response
    else
      return nil
    end
  end
  return args, after
end
local function post_string(string, meta)
  return make(string, meta)
end
local function post_file(file, meta)
  return make(("<" .. file), meta)
end
return {["post-string"] = post_string, ["post-file"] = post_file}