local _local_1_ = require("paperplanes.util.providers")
local set_field = _local_1_["set-field"]
local opts_to_fields = _local_1_["opts-to-fields"]
local function make(content_arg, meta, opts)
  local args
  do
    local _2_ = opts_to_fields(opts)
    set_field(_2_, "format", "default")
    set_field(_2_, "content", content_arg)
    set_field(_2_, "filename", meta.filename)
    table.insert(_2_, "https://dpaste.org/api/")
    args = _2_
  end
  local function after(response, status)
    local _3_ = status
    if (_3_ == 200) then
      return string.match(response, "\"(.*)\"")
    elseif true then
      local _ = _3_
      return nil, response
    else
      return nil
    end
  end
  return args, after
end
local function post_string(string, meta, opts)
  return make(string, meta, opts)
end
local function post_file(file, meta, opts)
  return make(("<" .. file), meta, opts)
end
return {["post-string"] = post_string, ["post-file"] = post_file}