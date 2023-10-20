local fmt = string.format
local function provide(content, metadata, opts, on_complete)
  assert((true == opts.insecure), "sprunge.us support is disabled as it does not support https. You must set the provider option insecure = true")
  local curl = require("paperplanes.curl")
  local temp_filename = vim.fn.tempname()
  local args = {"--data-urlencode", fmt("sprunge@%s", temp_filename), "http://sprunge.us"}
  local resp_handler
  local function _1_(response, status)
    vim.loop.fs_unlink(temp_filename)
    if (status == 200) then
      return on_complete(string.match(response, "^(http://.*)\n"))
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  resp_handler = _1_
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
    local function _4_()
      return outfile:write(content)
    end
    close_handlers_10_auto(_G.xpcall(_4_, (package.loaded.fennel or debug).traceback))
  end
  return curl(args, resp_handler)
end
return provide