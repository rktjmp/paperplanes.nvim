local fmt = string["format"]
local uv = (vim.uv or vim.loop)
local function completions()
  return {create = {"expires=hours", "expires=epochms", "secret=true"}, delete = {"token=key"}}
end
local function create(content, _content_metadata, options, on_complete)
  local curl = require("paperplanes.curl")
  local filename = vim.fn.tempname()
  local args
  do
    local a = {"-F", ("file=@" .. filename)}
    for key, val in pairs(options) do
      table.insert(a, "-F")
      table.insert(a, (key .. "=" .. val))
      a = a
    end
    args = a
  end
  local response_handler
  local function _2_(_1_)
    local response = _1_["response"]
    local status = _1_["status"]
    local headers = _1_["headers"]
    uv.fs_unlink(filename)
    if (status == 200) then
      local url = string.match(response, "(https://.*)\n")
      local token = headers["x-token"]
      local expires = headers["x-expires"]
      local token0
      do
        local t_3_ = token
        if (nil ~= t_3_) then
          t_3_ = t_3_[1]
        else
        end
        token0 = t_3_
      end
      local expires0
      do
        local t_5_ = expires
        if (nil ~= t_5_) then
          t_5_ = t_5_[1]
        else
        end
        expires0 = t_5_
      end
      return on_complete(url, {token = token0, expires = expires0})
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
    local function _9_()
      return outfile:write(content)
    end
    local _11_
    do
      local t_10_ = _G
      if (nil ~= t_10_) then
        t_10_ = t_10_.package
      else
      end
      if (nil ~= t_10_) then
        t_10_ = t_10_.loaded
      else
      end
      if (nil ~= t_10_) then
        t_10_ = t_10_.fennel
      else
      end
      _11_ = t_10_
    end
    local or_15_ = _11_ or _G.debug
    if not or_15_ then
      local function _16_()
        return ""
      end
      or_15_ = {traceback = _16_}
    end
    close_handlers_12_(_G.xpcall(_9_, or_15_.traceback))
  end
  return curl("https://0x0.st", args, response_handler)
end
local function delete(context, _options, on_complete)
  local url = context[1]
  local _let_17_ = context[2]
  local token = _let_17_["token"]
  if (nil ~= token) then
    local token0 = token
    local curl = require("paperplanes.curl")
    local args = {"-F", ("token=" .. token0), "-F", "delete=true", url}
    local response_handler
    local function _19_(_18_)
      local response = _18_["response"]
      local status = _18_["status"]
      local headers = _18_["headers"]
      if (status == 200) then
        return on_complete(url, {})
      else
        local _ = status
        return on_complete(nil, response)
      end
    end
    response_handler = _19_
    return curl(url, args, response_handler)
  elseif (token == nil) then
    local msg = fmt(table.concat({"No token recorded for %s, unable to delete.", "(The paste may have matched an existing hash and no token was returned)"}, "\n"), url)
    return on_complete(nil, msg)
  else
    return nil
  end
end
return {create = create, delete = delete, completions = completions}