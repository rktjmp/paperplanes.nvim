local _local_1_ = require("paperplanes.fn")
local reduce = _local_1_["reduce"]
local list_put = _local_1_["list-put"]
local list_append = _local_1_["list-append"]
local map_put = _local_1_["map-put"]
local fmt = string.format
local function provide(content, metadata, opts, on_complete)
  assert((true == opts.insecure), "ix.io support is disabled as it does not support https. You must set the provider option insecure = true")
  local curl = require("paperplanes.curl")
  local temp_filename = vim.fn.tempname()
  local defaults = {["name:1"] = metadata.filename, ["ext:1"] = metadata.extension}
  local args
  local function _2_(_241)
    map_put(_241, "insecure", nil)
    return _241
  end
  local function _3_(_241, _242, _243)
    return map_put(_243, _241, _242)
  end
  local function _4_(_241, _242, _243)
    return list_append(_243, {"--data-urlencode", fmt("%s=%s", _241, _242)})
  end
  args = list_put(list_append(reduce(_2_(reduce(opts, defaults, _3_)), {}, _4_), {"--data-urlencode", fmt("f:1@%s", temp_filename)}), "http://ix.io/")
  local resp_handler
  local function _5_(response, status)
    vim.loop.fs_unlink(temp_filename)
    if (status == 200) then
      return on_complete(string.match(response, "(http://.*)\n"))
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  resp_handler = _5_
  do
    local outfile = io.open(temp_filename, "w")
    local function close_handlers_10_auto(ok_11_auto, ...)
      outfile:close()
      if ok_11_auto then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _8_()
      return outfile:write(content)
    end
    close_handlers_10_auto(_G.xpcall(_8_, (package.loaded.fennel or debug).traceback))
  end
  return curl(args, resp_handler)
end
return provide