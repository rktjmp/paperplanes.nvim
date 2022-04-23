local uv = vim.loop
local _local_1_ = require("paperplanes.util.get_text")
local get_range = _local_1_["get-range"]
local get_selection = _local_1_["get-selection"]
local get_buf = _local_1_["get-buf"]
local options = {register = "+", provider = "0x0.st", provider_options = {}}
local function assert_curl()
  return assert((vim.fn.executable("curl") == 1), "paperplanes.nvim could not find curl executable")
end
local function get_option(name)
  return options[name]
end
local function get_provider(provider)
  local _2_ = (require("paperplanes.providers"))[provider]
  if (nil ~= _2_) then
    local any = _2_
    return any
  elseif (_2_ == nil) then
    return error(("paperplanes doesn't know provider: " .. provider))
  else
    return nil
  end
end
local function get_buffer_info(buffer)
  local api = vim.api
  local function _4_()
    return {path = vim.fn.expand("%:p"), filename = vim.fn.expand("%:t"), extension = vim.fn.expand("%:e"), filetype = vim.bo.filetype}
  end
  return api.nvim_buf_call(buffer, _4_)
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
    else
    end
    if not (code == 0) then
      error(("curl exited with non-zero status: " .. code))
    else
    end
    local response, status = string.match(raw, "(.*)\n(%d+)$")
    local url, err = provider_cb(response, tonumber(status))
    return final_cb(url, err)
  end
  print(string.format("%s'ing...", get_option("provider")))
  uv.spawn(cmd, {args = args, stdio = {nil, stdout, stderr}}, vim.schedule_wrap(on_exit))
  local function _7_(err, data)
    assert(not err, err)
    if data then
      return table.insert(errput, data)
    else
      return nil
    end
  end
  uv.read_start(stderr, _7_)
  local function _9_(err, data)
    assert(not err, err)
    if data then
      return table.insert(output, data)
    else
      return nil
    end
  end
  return uv.read_start(stdout, _9_)
end
local function post_string(content, meta, cb)
  local provider = get_provider(get_option("provider"))
  local provider_opts = get_option("provider_options")
  local args, after = provider["post-string"](content, meta, provider_opts)
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
    local _11_ = {url, err}
    if ((_G.type(_11_) == "table") and ((_11_)[1] == nil) and ((_11_)[2] == err)) then
      return error(("paperplanes got no url back from provider: " .. err))
    elseif ((_G.type(_11_) == "table") and ((_11_)[1] == url) and true) then
      local _ = (_11_)[2]
      local reg = get_option("register")
      if reg then
        vim.fn.setreg(reg, url)
        return print(string.format("\"%s = %s", reg, url))
      else
        return print(url)
      end
    else
      return nil
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
return {setup = setup, ["post-string"] = post_string, ["post-range"] = post_range, ["post-selection"] = post_selection, ["post-buffer"] = post_buffer, post_string = post_string, post_range = post_range, post_selection = post_selection, post_buffer = post_buffer, cmd = cmd}