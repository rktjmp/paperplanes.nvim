local fmt = string["format"]
local uv = (vim.uv or vim.loop)
local function completions()
  return {create = {"command=nc", "host=", "port="}}
end
local function find_command(options)
  local function find_installed_netcat()
    local command = nil
    for _, test in ipairs({"nc", "ncat", "netcat"}) do
      if command then break end
      local _1_ = vim.fn.executable(test)
      if (_1_ == 1) then
        command = test
      else
        command = nil
      end
    end
    return command
  end
  local function _3_(...)
    local _4_ = ...
    if (_4_ == nil) then
      local function _5_(...)
        local _6_ = ...
        if (_6_ == nil) then
          return error(table.concat({"Could not find executable `nc`, `ncat` or `netcat`, ", "and no `command` provider option was set.\n", "Please install a netcat compatible tool or set `command`."}, ""))
        elseif (nil ~= _6_) then
          local command = _6_
          return command
        else
          return nil
        end
      end
      return _5_(find_installed_netcat())
    elseif (nil ~= _4_) then
      local command = _4_
      return command
    else
      return nil
    end
  end
  return _3_(options.command)
end
local function create(content, _content_metadata, options, on_complete)
  local _let_9_ = require("paperplanes.exec")
  local exec = _let_9_["exec"]
  local command = find_command(options)
  local host = (options.host or "termbin.com")
  local port = (options.port or "9999")
  local on_exit
  local function _10_(exit_code, output, errors)
    if (exit_code == 0) then
      local _11_ = string.match(output, "(.+)\n.*")
      if (nil ~= _11_) then
        local url = _11_
        return on_complete(url, {})
      elseif (_11_ == nil) then
        return on_complete(nil, fmt("Could not match url from output: %s", vim.json.encode(output)))
      else
        return nil
      end
    else
      local _ = exit_code
      return on_complete(nil, fmt("exit: %s, errors: %s", exit_code, errors))
    end
  end
  on_exit = _10_
  local on_spawn
  local function _15_(_14_)
    local stdin = _14_["stdin"]
    return uv.write(stdin, content)
  end
  on_spawn = _15_
  return exec(command, {host, port}, on_exit, on_spawn)
end
return {create = create, completions = completions}