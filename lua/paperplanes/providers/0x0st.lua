local _local_1_ = require("paperplanes.util.providers")
local set_field = _local_1_["set-field"]
local function post_file(filename, meta, maybe_cleanup)
  local args
  do
    local _2_ = {}
    set_field(_2_, "file", ("@" .. filename))
    table.insert(_2_, "http://0x0.st")
    args = _2_
  end
  local function after(response, status)
    if maybe_cleanup then
      maybe_cleanup()
    else
    end
    local _4_ = status
    if (_4_ == 200) then
      return string.match(response, "(http://.*)\n")
    elseif true then
      local _ = _4_
      return nil, response
    else
      return nil
    end
  end
  return args, after
end
local function post_string(string, meta)
  local filename = vim.fn.tempname()
  do
    local outfile = io.open(filename, "w")
    local function close_handlers_8_auto(ok_9_auto, ...)
      outfile:close()
      if ok_9_auto then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _7_()
      return outfile:write(string)
    end
    close_handlers_8_auto(_G.xpcall(_7_, (package.loaded.fennel or debug).traceback))
  end
  local function cleanup()
    return vim.loop.fs_unlink(filename)
  end
  return post_file(filename, meta, cleanup)
end
return {["post-string"] = post_string, ["post-file"] = post_file}