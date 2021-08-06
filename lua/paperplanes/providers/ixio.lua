local _local_0_ = require("paperplanes.util.providers")
local set_field = _local_0_["set-field"]
local function make(content_arg, meta)
  local args
  do
    local _0_ = {}
    set_field(_0_, "f:1", content_arg)
    set_field(_0_, "name:1", meta.filename)
    set_field(_0_, "ext:1", meta.extension)
    table.insert(_0_, "http://ix.io")
    args = _0_
  end
  local function after(response, status)
    local _1_ = status
    if (_1_ == 200) then
      return string.match(response, "(http://.*)\n")
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