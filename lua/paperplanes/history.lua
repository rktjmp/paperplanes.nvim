local function path()
  return vim.fs.joinpath(vim.fn.stdpath("data"), "paperplanes_history.json")
end
local function read()
  local function open_or_create_file()
    local function _1_(...)
      local _2_ = ...
      if (nil ~= _2_) then
        local file = _2_
        return file
      else
        local _ = _2_
        do
          local file = io.open(path(), "w")
          file:write("[]")
          file:close()
        end
        return open_or_create_file()
      end
    end
    return _1_(io.open(path()))
  end
  return vim.json.decode(open_or_create_file():read("*a"))
end
local function append(provider_name, action, url, paste_data)
  _G.assert((nil ~= paste_data), "Missing argument paste-data on fnl/paperplanes/history.fnl:39")
  _G.assert((nil ~= url), "Missing argument url on fnl/paperplanes/history.fnl:39")
  _G.assert((nil ~= action), "Missing argument action on fnl/paperplanes/history.fnl:39")
  _G.assert((nil ~= provider_name), "Missing argument provider-name on fnl/paperplanes/history.fnl:39")
  local new_event = {provider = provider_name, action = action, url = url, meta = paste_data, at = os.date("!%Y-%m-%dT%H:%M:%SZ")}
  local data = read()
  local _ = table.insert(data, new_event)
  local updated_history = vim.json.encode(data)
  do
    local f = io.open(path(), "w+")
    local function close_handlers_12_(ok_13_, ...)
      f:close()
      if ok_13_ then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _5_()
      return f:write(updated_history)
    end
    local _7_
    do
      local t_6_ = _G
      if (nil ~= t_6_) then
        t_6_ = t_6_.package
      else
      end
      if (nil ~= t_6_) then
        t_6_ = t_6_.loaded
      else
      end
      if (nil ~= t_6_) then
        t_6_ = t_6_.fennel
      else
      end
      _7_ = t_6_
    end
    local or_11_ = _7_ or _G.debug
    if not or_11_ then
      local function _12_()
        return ""
      end
      or_11_ = {traceback = _12_}
    end
    close_handlers_12_(_G.xpcall(_5_, or_11_.traceback))
  end
  return true
end
return {append = append, read = read, path = path}