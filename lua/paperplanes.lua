






 local uv = vim.loop
 local _local_1_ = require("paperplanes.get_text") local get_range = _local_1_["get-range"]
 local get_selection = _local_1_["get-selection"]
 local get_buf = _local_1_["get-buf"]
 local _local_2_ = string local fmt = _local_2_["format"]


 local options = {register = "+", provider = "0x0.st", provider_options = {}, notifier = (vim.notify or print)}




 local function get_option(name)
 return options[name] end

 local function get_provider(name)
 local providers = require("paperplanes.providers")
 local provider = providers[name]
 return (provider or error(fmt("paperplanes doesn't know provider: %q", name))) end

 local function notify(string)
 return get_option("notifier")(string) end

 local function get_buffer_meta(buffer)


 local function _3_() return {path = vim.fn.expand("%:p"), filename = vim.fn.expand("%:t"), extension = vim.fn.expand("%:e"), filetype = vim.bo.filetype} end return vim.api.nvim_buf_call(buffer, _3_) end




 local function post_string(content, file_meta, callback, _3fprovider_name, _3fprovider_options) do assert((nil ~= content), string.format("paperplanes.%s requires %s argument", "post-string", "content")) assert((nil ~= file_meta), string.format("paperplanes.%s requires %s argument", "post-string", "file-meta")) assert((nil ~= callback), string.format("paperplanes.%s requires %s argument", "post-string", "callback")) end

 local default_name = get_option("provider")
 local default_opts = get_option("provider_options")
 local function _6_() local _5_ = _3fprovider_name if (_5_ == nil) then return {default_name, default_opts} elseif (_5_ == default_name) then return {default_name, (_3fprovider_options or default_opts)} elseif true then local _ = _5_ return {_3fprovider_name, (_3fprovider_options or {})} else return nil end end local _let_4_ = _6_() local provider_name = _let_4_[1] local provider_options = _let_4_[2]






 local provider = get_provider(provider_name)
 return provider(content, file_meta, provider_options, callback) end

 local function post_range(buffer, start, stop, cb, _3fprovider_name, _3fprovider_options) do assert((nil ~= buffer), string.format("paperplanes.%s requires %s argument", "post-range", "buffer")) assert((nil ~= start), string.format("paperplanes.%s requires %s argument", "post-range", "start")) assert((nil ~= stop), string.format("paperplanes.%s requires %s argument", "post-range", "stop")) end

 local content = get_range(buffer, start, stop)
 local buffer_meta = get_buffer_meta(buffer)
 return post_string(content, buffer_meta, cb, _3fprovider_name, _3fprovider_options) end

 local function post_selection(callback, _3fprovider_name, _3fprovider_options) do assert((nil ~= callback), string.format("paperplanes.%s requires %s argument", "post-selection", "callback")) end

 local content = get_selection()
 local buffer_meta = get_buffer_meta(0)
 return post_string(content, buffer_meta, callback, _3fprovider_name, __fnl_global___3fprovider_2dopts) end

 local function post_buffer(buffer, callback, _3fprovider_name, _3fprovider_options) do assert((nil ~= buffer), string.format("paperplanes.%s requires %s argument", "post-buffer", "buffer")) assert((nil ~= callback), string.format("paperplanes.%s requires %s argument", "post-buffer", "callback")) end

 local content = get_buf(buffer)
 local buffer_meta = get_buffer_meta(buffer)
 return post_string(content, buffer_meta, callback, _3fprovider_name, _3fprovider_options) end

 local function cmd(start, stop) do assert((nil ~= start), string.format("paperplanes.%s requires %s argument", "cmd", "start")) assert((nil ~= stop), string.format("paperplanes.%s requires %s argument", "cmd", "stop")) end


 local function maybe_set_and_print(url, err)

 local _8_ = {url, err} if ((_G.type(_8_) == "table") and ((_8_)[1] == nil) and ((_8_)[2] == err)) then
 return error(fmt("paperplanes got no url back from provider: %s", err)) elseif ((_G.type(_8_) == "table") and ((_8_)[1] == url) and true) then local _ = (_8_)[2]
 local reg = get_option("register") local msg_prefix
 if reg then msg_prefix = fmt("\"%s = ", reg) else msg_prefix = "" end
 local msg = fmt("%s%s", msg_prefix, url)
 if reg then vim.fn.setreg(reg, url) else end
 return notify(msg) else return nil end end
 local provider_name = get_option("provider")
 local provider_options = get_option("provider_options")
 notify(fmt("%s'ing...", provider_name))
 return post_range(0, start, stop, maybe_set_and_print, provider_name, provider_options) end

 local function setup(opts) do assert((nil ~= opts), string.format("paperplanes.%s requires %s argument", "setup", "opts")) end




 for k, v in pairs(opts) do
 options[k] = v end return nil end

 return {setup = setup, ["post-string"] = post_string, ["post-range"] = post_range, ["post-selection"] = post_selection, ["post-buffer"] = post_buffer, post_string = post_string, post_range = post_range, post_selection = post_selection, post_buffer = post_buffer, cmd = cmd}