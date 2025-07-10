local fmt = string["format"]
local uv = vim["loop"]
local _local_1_ = require("paperplanes.exec")
local exec = _local_1_["exec"]
local function clean_up(status_path, header_path)
  _G.assert((nil ~= header_path), "Missing argument header-path on fnl/paperplanes/curl.fnl:8")
  _G.assert((nil ~= status_path), "Missing argument status-path on fnl/paperplanes/curl.fnl:8")
  os.remove(status_path)
  return os.remove(header_path)
end
local function process_return(status_path, header_path, response_body)
  _G.assert((nil ~= response_body), "Missing argument response-body on fnl/paperplanes/curl.fnl:12")
  _G.assert((nil ~= header_path), "Missing argument header-path on fnl/paperplanes/curl.fnl:12")
  _G.assert((nil ~= status_path), "Missing argument status-path on fnl/paperplanes/curl.fnl:12")
  local status_file = io.open(status_path, "r")
  local header_file = io.open(header_path, "r")
  local function close_handlers_12_(ok_13_, ...)
    header_file:close()
    status_file:close()
    if ok_13_ then
      return ...
    else
      return error(..., 0)
    end
  end
  local function _3_()
    local status = status_file:read("*n")
    local headers = vim.json.decode(header_file:read("*a"))
    return {status = status, headers = headers, response = response_body}
  end
  local _5_
  do
    local t_4_ = _G
    if (nil ~= t_4_) then
      t_4_ = t_4_.package
    else
    end
    if (nil ~= t_4_) then
      t_4_ = t_4_.loaded
    else
    end
    if (nil ~= t_4_) then
      t_4_ = t_4_.fennel
    else
    end
    _5_ = t_4_
  end
  local or_9_ = _5_ or _G.debug
  if not or_9_ then
    local function _10_()
      return ""
    end
    or_9_ = {traceback = _10_}
  end
  return close_handlers_12_(_G.xpcall(_3_, or_9_.traceback))
end
local function curl(url, request_args, response_handler)
  assert((vim.fn.executable("curl") == 1), fmt("paperplanes.nvim could not find %q executable", "curl"))
  local status_path = vim.fn.tempname()
  local header_path = vim.fn.tempname()
  local output_format = string.format("%%output{%s}%%{response_code}%%output{%s}%%{header_json}", status_path, header_path)
  local args = vim.iter({"--silent", "--show-error", "--write-out", output_format, request_args, url}):flatten():totable()
  local on_exit
  local function _11_(exit_code, output, errors)
    local _12_, _13_ = exit_code, errors
    if ((_12_ == 0) and (_13_ == "")) then
      return response_handler(process_return(status_path, header_path, output))
    else
      local _ = _12_
      local msg = "curl encounted an error:\nexit-code: %s\nerror message: %s"
      clean_up(status_path, header_path)
      return vim.notify(string.format(msg, exit_code, errors), vim.log.levels.ERROR)
    end
  end
  on_exit = _11_
  return exec("curl", args, on_exit)
end
return curl