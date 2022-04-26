local uv = vim.loop
local _local_1_ = require("paperplanes.util.get_text")
local get_range = _local_1_["get-range"]
local get_selection = _local_1_["get-selection"]
local get_buf = _local_1_["get-buf"]
local _local_2_ = string
local fmt = _local_2_["format"]
local options = {register = "+", provider = "0x0.st", provider_options = {}, cmd = "curl"}
local function get_option(name)
  return options[name]
end
local function get_provider(name)
  local providers = require("paperplanes.providers")
  local provider = providers[name]
  return (provider or error(fmt("paperplanes doesn't know provider: %q", name)))
end
local function execute_request(post_args, provider_cb, final_cb)
  assert(final_cb, "paperplanes provided no final cb")
  local cmd = get_option("cmd")
  local request_handler = require("paperplanes.util.curl")
  local notify_attempt
  local function _3_()
    local msg = fmt("%s'ing...", get_option("provider"))
    local show = (vim.notify or print)
    return show(msg)
  end
  notify_attempt = _3_
  notify_attempt()
  return request_handler(cmd, post_args, provider_cb, final_cb)
end
local function get_buffer_meta(buffer)
  local function _4_()
    return {path = vim.fn.expand("%:p"), filename = vim.fn.expand("%:t"), extension = vim.fn.expand("%:e"), filetype = vim.bo.filetype}
  end
  return vim.api.nvim_buf_call(buffer, _4_)
end
local function post_string(content, meta, cb)
  local provider = get_provider(get_option("provider"))
  local provider_opts = get_option("provider_options")
  local args, resp_handler = provider(content, meta, provider_opts)
  return execute_request(args, resp_handler, cb)
end
local function post_range(buf, start, stop, cb)
  local content = get_range(buf, start, stop)
  local buffer_meta = get_buffer_meta(buf)
  return post_string(content, buffer_meta, cb)
end
local function post_selection(cb)
  local content = get_selection()
  local buffer_meta = get_buffer_meta(0)
  return post_string(content, buffer_meta, cb)
end
local function post_buffer(buffer, cb)
  assert(buffer, "paperplanes post-buffer: must provide buffer")
  local content = get_buf(buffer)
  local buffer_meta = get_buffer_meta(buffer)
  return post_string(content, buffer_meta, cb)
end
local function cmd(start, stop)
  local function maybe_set_and_print(url, err)
    local _5_ = {url, err}
    if ((_G.type(_5_) == "table") and ((_5_)[1] == nil) and ((_5_)[2] == err)) then
      return error(("paperplanes got no url back from provider: " .. err))
    elseif ((_G.type(_5_) == "table") and ((_5_)[1] == url) and true) then
      local _ = (_5_)[2]
      local reg = get_option("register")
      local set_reg
      local function _6_(_241, _242)
        return (_241 and vim.fn.setreg(_241, _242))
      end
      set_reg = _6_
      local notify
      local function _7_(_241, _242)
        local extra
        if _242 then
          extra = fmt("\"%s = ", _242)
        else
          extra = ""
        end
        local msg = fmt("%s%s", extra, _241)
        local via = (vim.notify or print)
        return via(msg)
      end
      notify = _7_
      set_reg(reg, url)
      return notify(url, reg)
    else
      return nil
    end
  end
  return post_range(0, start, stop, maybe_set_and_print)
end
local function setup(opts)
  for k, v in pairs(opts) do
    options[k] = v
  end
  return nil
end
return {setup = setup, ["post-string"] = post_string, ["post-range"] = post_range, ["post-selection"] = post_selection, ["post-buffer"] = post_buffer, post_string = post_string, post_range = post_range, post_selection = post_selection, post_buffer = post_buffer, cmd = cmd}