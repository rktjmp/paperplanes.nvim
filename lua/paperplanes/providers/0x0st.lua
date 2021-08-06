local _local_0_ = require("paperplanes.util.providers")
local set_field = _local_0_["set-field"]
local function post_file(filename, meta, maybe_cleanup)
  local args
  do
    local _0_ = {}
    set_field(_0_, "file", ("@" .. filename))
    table.insert(_0_, "http://0x0.st")
    args = _0_
  end
  print(vim.inspect(args))
  local function after(response, status)
    if maybe_cleanup then
      maybe_cleanup()
    end
    local _2_ = status
    if (_2_ == 200) then
      return string.match(response, "(http://.*)\n")
    else
      local _ = _2_
      return nil, response
    end
  end
  return args, after
end
local function post_string(string, meta)
  local filename = vim.fn.tempname()
  do
    local outfile = io.open(filename, "w")
    local function close_handlers_0_(ok_0_, ...)
      outfile:close()
      if ok_0_ then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _0_()
      return outfile:write(string)
    end
    close_handlers_0_(xpcall(_0_, (package.loaded.fennel or debug).traceback))
  end
  local function cleanup()
    return vim.loop.fs_unlink(filename)
  end
  return post_file(filename, meta, cleanup)
end
return {["post-file"] = post_file, ["post-string"] = post_string}