local fmt = string["format"]
local configuration = {register = "+", provider = "0x0.st", provider_options = {}, notifier = (vim.notify or print), save_history = true}
local function setup(opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/paperplanes.fnl:10")
  for k, v in pairs(opts) do
    configuration[k] = v
  end
  return nil
end
local function get_config_option(key)
  return vim.deepcopy(configuration[key])
end
local function save_to_history(...)
  if get_config_option("save_history") then
    return require("paperplanes.history").append(...)
  else
    return nil
  end
end
local known_instance_data = {}
local function get_known_instance_data(provider_name, buffer_id)
  local t_2_ = known_instance_data
  if (nil ~= t_2_) then
    t_2_ = t_2_[provider_name]
  else
  end
  if (nil ~= t_2_) then
    t_2_ = t_2_[buffer_id]
  else
  end
  return t_2_
end
local function set_known_instance_data(provider_name, buffer_id, url, data)
  local pdata = (known_instance_data[provider_name] or {})
  pdata[buffer_id] = {url, data}
  known_instance_data[provider_name] = pdata
  return nil
end
local function unset_known_instance_data(provider_name, buffer_id, url, data)
  local pdata = (known_instance_data[provider_name] or {})
  pdata[buffer_id] = nil
  known_instance_data[provider_name] = pdata
  return nil
end
local function resolve_provider_context(_3fprovider_name, _3fprovider_options, action)
  local provider_name = (_3fprovider_name or get_config_option("provider"))
  local provider_options = (_3fprovider_options or get_config_option("provider_options"))
  local providers = require("paperplanes.providers")
  local provider = providers[provider_name]
  local action_fn
  do
    local t_5_ = provider
    if (nil ~= t_5_) then
      t_5_ = t_5_[action]
    else
    end
    action_fn = t_5_
  end
  local _7_, _8_ = provider, action_fn
  if ((_7_ == nil) and true) then
    local _ = _8_
    return error(fmt("paperplanes doesn't know provider: %q", provider_name))
  elseif (true and (_8_ == nil)) then
    local _ = _7_
    return error(fmt("paperplanes provider %s does not support action: %q", provider_name, action))
  else
    local _ = _7_
    return {name = provider_name, action = action_fn, options = provider_options}
  end
end
local function create(unique_id, content_string, content_metadata, on_complete, _3fprovider_name, _3fprovider_options)
  _G.assert((nil ~= on_complete), "Missing argument on-complete on fnl/paperplanes.fnl:53")
  _G.assert((nil ~= content_metadata), "Missing argument content-metadata on fnl/paperplanes.fnl:53")
  _G.assert((nil ~= content_string), "Missing argument content-string on fnl/paperplanes.fnl:53")
  _G.assert((nil ~= unique_id), "Missing argument unique-id on fnl/paperplanes.fnl:53")
  local provider = resolve_provider_context(_3fprovider_name, _3fprovider_options, "create")
  local on_complete0
  local function _10_(url, meta)
    if url then
      save_to_history(provider.name, "create", url, meta)
      set_known_instance_data(provider.name, unique_id, url, meta)
    else
    end
    return on_complete(url, meta)
  end
  on_complete0 = _10_
  return provider.action(content_string, content_metadata, provider.options, on_complete0)
end
local function update(unique_id, content_string, content_metadata, on_complete, _3fprovider_name, _3fprovider_options)
  _G.assert((nil ~= on_complete), "Missing argument on-complete on fnl/paperplanes.fnl:62")
  _G.assert((nil ~= content_metadata), "Missing argument content-metadata on fnl/paperplanes.fnl:62")
  _G.assert((nil ~= content_string), "Missing argument content-string on fnl/paperplanes.fnl:62")
  _G.assert((nil ~= unique_id), "Missing argument unique-id on fnl/paperplanes.fnl:62")
  local provider = resolve_provider_context(_3fprovider_name, _3fprovider_options, "update")
  local on_complete0
  local function _12_(url, meta)
    if url then
      save_to_history(provider.name, "update", url, meta)
      set_known_instance_data(provider.name, unique_id, url, meta)
    else
    end
    return on_complete(url, meta)
  end
  on_complete0 = _12_
  local _14_ = get_known_instance_data(provider.name, unique_id)
  if (nil ~= _14_) then
    local context = _14_
    return provider.action(context, content_string, content_metadata, provider.options, on_complete0)
  elseif (_14_ == nil) then
    return error(fmt("Unable to update, no known data for %s in this neovim instance", unique_id))
  else
    return nil
  end
end
local function delete(unique_id, on_complete, _3fprovider_name, _3fprovider_options)
  _G.assert((nil ~= on_complete), "Missing argument on-complete on fnl/paperplanes.fnl:73")
  _G.assert((nil ~= unique_id), "Missing argument unique-id on fnl/paperplanes.fnl:73")
  local provider = resolve_provider_context(_3fprovider_name, _3fprovider_options, "delete")
  local on_complete0
  local function _16_(url, meta)
    if url then
      save_to_history(provider.name, "delete", url, meta)
      unset_known_instance_data(provider.name, unique_id)
    else
    end
    return on_complete(url, meta)
  end
  on_complete0 = _16_
  local _18_ = get_known_instance_data(provider.name, unique_id)
  if (nil ~= _18_) then
    local context = _18_
    return provider.action(context, provider.options, on_complete0)
  elseif (_18_ == nil) then
    return error(fmt("Unable to delete, no known data for %s in this neovim instance", unique_id))
  else
    return nil
  end
end
local function history_path()
  return require("paperplanes.history").path()
end
return {setup = setup, ["get-config-option"] = get_config_option, create = create, update = update, delete = delete, ["history-path"] = history_path, history_path = history_path}