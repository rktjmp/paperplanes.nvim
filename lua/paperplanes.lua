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
  local default_provider_name = get_config_option("provider")
  local provider_name = (_3fprovider_name or default_provider_name)
  local provider_options
  do
    local default_options = get_config_option("provider_options")
    local using_default_provider_3f = (provider_name == default_provider_name)
    local _5_, _6_ = using_default_provider_3f, (_3fprovider_options or {})
    if ((_5_ == true) and (nil ~= _6_)) then
      local any_options = _6_
      provider_options = vim.tbl_extend("force", default_options, any_options)
    elseif ((_5_ == false) and (nil ~= _6_)) then
      local any_options = _6_
      provider_options = any_options
    else
      provider_options = nil
    end
  end
  local providers = require("paperplanes.providers")
  local provider = providers[provider_name]
  local action_fn
  do
    local t_8_ = provider
    if (nil ~= t_8_) then
      t_8_ = t_8_[action]
    else
    end
    action_fn = t_8_
  end
  local _10_, _11_ = provider, action_fn
  if ((_10_ == nil) and true) then
    local _ = _11_
    return error(fmt("paperplanes doesn't know provider: %q", provider_name))
  elseif (true and (_11_ == nil)) then
    local _ = _10_
    return error(fmt("paperplanes provider %s does not support action: %q", provider_name, action))
  else
    local _ = _10_
    return {name = provider_name, action = action_fn, options = provider_options}
  end
end
local function clean_content_metadata(metadata)
  local tbl_16_ = {}
  for k, v in pairs(metadata) do
    local k_17_, v_18_ = nil, nil
    if (v == "") then
      k_17_, v_18_ = k, nil
    elseif (nil ~= v) then
      local other = v
      k_17_, v_18_ = k, v
    else
      k_17_, v_18_ = nil
    end
    if ((k_17_ ~= nil) and (v_18_ ~= nil)) then
      tbl_16_[k_17_] = v_18_
    else
    end
  end
  return tbl_16_
end
local function create(unique_id, content_string, content_metadata, on_complete, _3fprovider_name, _3fprovider_options)
  _G.assert((nil ~= on_complete), "Missing argument on-complete on fnl/paperplanes.fnl:68")
  _G.assert((nil ~= content_metadata), "Missing argument content-metadata on fnl/paperplanes.fnl:68")
  _G.assert((nil ~= content_string), "Missing argument content-string on fnl/paperplanes.fnl:68")
  _G.assert((nil ~= unique_id), "Missing argument unique-id on fnl/paperplanes.fnl:68")
  local provider = resolve_provider_context(_3fprovider_name, _3fprovider_options, "create")
  local content_metadata0 = clean_content_metadata(content_metadata)
  local on_complete0
  local function _15_(url, meta)
    local _16_, _17_ = url, meta
    if ((nil ~= _16_) and (nil ~= _17_)) then
      local url0 = _16_
      local meta0 = _17_
      save_to_history(provider.name, "create", url0, meta0)
      set_known_instance_data(provider.name, unique_id, url0, meta0)
      return on_complete(url0, meta0)
    elseif ((_16_ == nil) and (nil ~= _17_)) then
      local err = _17_
      return on_complete(nil, err)
    else
      return nil
    end
  end
  on_complete0 = _15_
  return provider.action(content_string, content_metadata0, provider.options, on_complete0)
end
local function update(unique_id, content_string, content_metadata, on_complete, _3fprovider_name, _3fprovider_options)
  _G.assert((nil ~= on_complete), "Missing argument on-complete on fnl/paperplanes.fnl:80")
  _G.assert((nil ~= content_metadata), "Missing argument content-metadata on fnl/paperplanes.fnl:80")
  _G.assert((nil ~= content_string), "Missing argument content-string on fnl/paperplanes.fnl:80")
  _G.assert((nil ~= unique_id), "Missing argument unique-id on fnl/paperplanes.fnl:80")
  local provider = resolve_provider_context(_3fprovider_name, _3fprovider_options, "update")
  local content_metadata0 = clean_content_metadata(content_metadata)
  local on_complete0
  local function _19_(url, meta)
    local _20_, _21_ = url, meta
    if ((nil ~= _20_) and (nil ~= _21_)) then
      local url0 = _20_
      local meta0 = _21_
      save_to_history(provider.name, "update", url0, meta0)
      set_known_instance_data(provider.name, unique_id, url0, meta0)
      return on_complete(url0)
    elseif ((_20_ == nil) and (nil ~= _21_)) then
      local err = _21_
      return on_complete(nil, err)
    else
      return nil
    end
  end
  on_complete0 = _19_
  local _23_ = get_known_instance_data(provider.name, unique_id)
  if (nil ~= _23_) then
    local context = _23_
    return provider.action(context, content_string, content_metadata0, provider.options, on_complete0)
  elseif (_23_ == nil) then
    return error(fmt("Unable to update, no known data for %s in this neovim instance", unique_id))
  else
    return nil
  end
end
local function delete(unique_id, on_complete, _3fprovider_name, _3fprovider_options)
  _G.assert((nil ~= on_complete), "Missing argument on-complete on fnl/paperplanes.fnl:94")
  _G.assert((nil ~= unique_id), "Missing argument unique-id on fnl/paperplanes.fnl:94")
  local provider = resolve_provider_context(_3fprovider_name, _3fprovider_options, "delete")
  local on_complete0
  local function _25_(url, meta)
    local _26_, _27_ = url, meta
    if ((nil ~= _26_) and (nil ~= _27_)) then
      local url0 = _26_
      local meta0 = _27_
      save_to_history(provider.name, "delete", url0, meta0)
      unset_known_instance_data(provider.name, unique_id)
      return on_complete(url0)
    elseif ((_26_ == nil) and (nil ~= _27_)) then
      local err = _27_
      return on_complete(nil, err)
    else
      return nil
    end
  end
  on_complete0 = _25_
  local _29_ = get_known_instance_data(provider.name, unique_id)
  if (nil ~= _29_) then
    local context = _29_
    return provider.action(context, provider.options, on_complete0)
  elseif (_29_ == nil) then
    return error(fmt("Unable to delete, no known data for %s in this neovim instance", unique_id))
  else
    return nil
  end
end
local function history_path()
  return require("paperplanes.history").path()
end
return {setup = setup, ["get-config-option"] = get_config_option, create = create, update = update, delete = delete, ["history-path"] = history_path, history_path = history_path}