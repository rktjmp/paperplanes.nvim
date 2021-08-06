local _local_0_ = require("paperplanes.util.providers")
local set_field = _local_0_["set-field"]
local function make(content_arg, meta)
  local args
  do
    local _0_ = {}
    set_field(_0_, "format", "default")
    set_field(_0_, "content", content_arg)
    set_field(_0_, "filename", meta.filename)
    table.insert(_0_, "https://dpaste.org/api/")
    args = _0_
  end
  local function after(response, status)
    print(response, status)
    local _1_ = status
    if (_1_ == 200) then
      return string.match(response, "\"(.*)\"")
    else
      local _ = _1_
      return nil, response
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
return {["post-file"] = post_file, ["post-string"] = post_string}