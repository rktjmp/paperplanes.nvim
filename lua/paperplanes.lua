local uv = vim.loop
local _local_0_ = require("paperplanes.util.get_text")
local get_buf = _local_0_["get-buf"]
local get_range = _local_0_["get-range"]
local get_selection = _local_0_["get-selection"]
local options = {provider = "0x0.st", register = "+"}
local function assert_curl()
  return assert((vim.fn.executable("curl") == 1), "paperplanes.nvim could not find curl executable")
end
local function get_option(name)
  return options[name]
end
local function get_provider(provider)
  local _0_ = (require("paperplanes.providers"))[provider]
  if (nil ~= _0_) then
    local any = _0_
    return any
  elseif (_0_ == nil) then
    return error(("paperplanes doesn't known provider: " .. provider))
  end
end
local function get_buffer_info(buffer)
  local api = vim.api
  local function _0_()
    return {extension = vim.fn.expand("%:e"), filename = vim.fn.expand("%:t"), filetype = vim.bo.filetype, path = vim.fn.expand("%:p")}
  end
  return api.nvim_buf_call(buffer, _0_)
end
local function make_post(post_args, provider_cb, final_cb)
  assert_curl()
  assert(final_cb, "paperplanes provided no final cb")
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local register = get_option("register")
  local cmd = "curl"
  local args = vim.tbl_flatten({"--silent", "--show-error", "--write-out", "\n%{response_code}", post_args})
  local output = {}
  local errput = {}
  local function on_exit(code, sig)
    uv.close(stdout)
    uv.close(stderr)
    local errors = table.concat(errput)
    local raw = table.concat(output)
    if not ("" == errors) then
      error(("paperplanes encountered an internal error: " .. errors))
    end
    if not (code == 0) then
      error(("curl exited with non-zero status: " .. code))
    end
    local response, status = string.match(raw, "(.*)\n(%d+)$")
    local url, err = provider_cb(response, tonumber(status))
    return final_cb(url, err)
  end
  print(string.format("%s'ing...", get_option("provider")))
  uv.spawn(cmd, {args = args, stdio = {nil, stdout, stderr}}, vim.schedule_wrap(on_exit))
  local function _0_(err, data)
    assert(not err, err)
    if data then
      return table.insert(errput, data)
    end
  end
  uv.read_start(stderr, _0_)
  local function _1_(err, data)
    assert(not err, err)
    if data then
      return table.insert(output, data)
    end
  end
  return uv.read_start(stdout, _1_)
end
local function post_string(content, meta, cb)
  local provider = get_provider(get_option("provider"))
  local args, after = provider["post-string"](content, meta)
  return make_post(args, after, cb)
end
local function post_range(buf, start, stop, cb)
  return post_string(get_range(buf, start, stop), get_buffer_info(buf), cb)
end
local function post_selection(cb)
  return post_string(get_selection(), get_buffer_info(0), cb)
end
local function post_buffer(buffer, cb)
  assert(buffer, "paperplanes post-buffer: must provide buffer")
  return post_string(get_buf(buffer), get_buffer_info(buffer), cb)
end
local function cmd(start, stop)
  local function maybe_set_and_print(url, err)
    local _0_ = {url, err}
    if ((type(_0_) == "table") and ((_0_)[1] == nil) and ((_0_)[2] == err)) then
      return error(("paperplanes got no url back from provider: " .. err))
    elseif ((type(_0_) == "table") and ((_0_)[1] == url) and true) then
      local _ = (_0_)[2]
      local reg = get_option("register")
      if reg then
        vim.fn.setreg(reg, url)
        return print(string.format("\"%s = %s", reg, url))
      else
        return print(url)
      end
    end
  end
  return post_range(0, start, stop, maybe_set_and_print)
end
local function setup(opts)
  assert_curl()
  for k, v in pairs(opts) do
    options[k] = v
  end
  return nil
end
return {["post-buffer"] = post_buffer, ["post-range"] = post_range, ["post-selection"] = post_selection, ["post-string"] = post_string, cmd = cmd, post_buffer = post_buffer, post_range = post_range, post_selection = post_selection, post_string = post_string, setup = setup}