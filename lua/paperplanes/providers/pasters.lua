local fmt = string["format"]
local function completions()
  return {create = {}, delete = {}}
end
local function create(content, metadata, _options, on_complete)
  local curl = require("paperplanes.curl")
  local filename = vim.fn.tempname()
  local args = {"--data-binary", ("@" .. filename)}
  local response_handler
  local function _2_(_1_)
    local response = _1_["response"]
    local status = _1_["status"]
    local headers = _1_["headers"]
    vim.loop.fs_unlink(filename)
    if ((status == 201) or (status == 206)) then
      local url
      do
        local _3_ = metadata.extension
        if (nil ~= _3_) then
          local ext = _3_
          url = (response .. "." .. ext)
        else
          local _ = _3_
          url = response
        end
      end
      return on_complete(url, {})
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  response_handler = _2_
  do
    local outfile = io.open(filename, "w")
    local function close_handlers_12_(ok_13_, ...)
      outfile:close()
      if ok_13_ then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _7_()
      return outfile:write(content)
    end
    local _9_
    do
      local t_8_ = _G
      if (nil ~= t_8_) then
        t_8_ = t_8_.package
      else
      end
      if (nil ~= t_8_) then
        t_8_ = t_8_.loaded
      else
      end
      if (nil ~= t_8_) then
        t_8_ = t_8_.fennel
      else
      end
      _9_ = t_8_
    end
    local or_13_ = _9_ or _G.debug
    if not or_13_ then
      local function _14_()
        return ""
      end
      or_13_ = {traceback = _14_}
    end
    close_handlers_12_(_G.xpcall(_7_, or_13_.traceback))
  end
  return curl("https://paste.rs", args, response_handler)
end
local function delete(context, _options, on_complete)
  local url = context[1]
  local _ = context[2]
  local curl = require("paperplanes.curl")
  local args = {"-X", "DELETE"}
  local response_handler
  local function _16_(_15_)
    local response = _15_["response"]
    local status = _15_["status"]
    local headers = _15_["headers"]
    if (status == 200) then
      return on_complete(url, {})
    else
      local _0 = status
      return on_complete(nil, response)
    end
  end
  response_handler = _16_
  return curl(url, args, response_handler)
end
return {create = create, delete = delete, completions = completions}