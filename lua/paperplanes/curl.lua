local _local_1_ = string
local fmt = _local_1_["format"]
local _local_2_ = vim
local uv = _local_2_["loop"]
local _local_3_ = require("paperplanes.exec")
local exec = _local_3_["exec"]
local function curl(request_args, response_handler)
  assert((vim.fn.executable("curl") == 1), fmt("paperplanes.nvim could not find %q executable", "curl"))
  local args = vim.tbl_flatten({"--silent", "--show-error", "--write-out", "\n%{response_code}", request_args})
  local on_exit
  local function _4_(exit_code, output, errors)
    assert(("" == errors), fmt("paperplanes encountered an internal error: %q", errors))
    assert((0 == exit_code), fmt("curl exited with non-zero status: %q", exit_code))
    local response, status = string.match(output, "(.*)\n(%d+)$")
    local status0 = tonumber(status)
    return response_handler(response, status0)
  end
  on_exit = _4_
  return exec("curl", args, on_exit)
end
return curl