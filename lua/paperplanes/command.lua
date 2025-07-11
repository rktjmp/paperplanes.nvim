local fmt = string["format"]
local function _1_(...)
  local keys = {"create", "update", "delete", "get-config-option"}
  local tbl_21_ = {}
  local i_22_ = 0
  for _, name in ipairs(keys) do
    local val_23_
    local function _2_(...)
      return require("paperplanes")[name](...)
    end
    val_23_ = _2_
    if (nil ~= val_23_) then
      i_22_ = (i_22_ + 1)
      tbl_21_[i_22_] = val_23_
    else
    end
  end
  return tbl_21_
end
local _local_4_ = _1_(...)
local create = _local_4_[1]
local update = _local_4_[2]
local delete = _local_4_[3]
local get_config_option = _local_4_[4]
local function provider_syntax_3f(x)
  return vim.startswith(x, "@")
end
local function run_command(_5_)
  local argv = _5_["fargs"]
  local range_enum = _5_["range"]
  local function notify(...)
    return get_config_option("notifier")(...)
  end
  local function create_text_range(buf_id, use_marks_3f)
    if (use_marks_3f == true) then
      local _let_6_ = vim.api.nvim_buf_get_mark(buf_id, "<")
      local start_row = _let_6_[1]
      local start_col = _let_6_[2]
      local _let_7_ = vim.api.nvim_buf_get_mark(buf_id, ">")
      local end_row = _let_7_[1]
      local end_col = _let_7_[2]
      local start_row0 = (start_row - 1)
      local end_row0 = (end_row - 1)
      local end_col0 = (end_col + 1)
      return {{start_row0, start_col}, {end_row0, end_col0}}
    elseif (use_marks_3f == false) then
      local line_count = vim.api.nvim_buf_line_count(buf_id)
      return {{0, 0}, {(line_count - 1), 2147483648}}
    else
      return nil
    end
  end
  local function parse_provider_options(raw_options)
    if ((_G.type(raw_options) == "table") and (raw_options[1] == nil)) then
      return nil
    else
      local _ = raw_options
      local tbl_16_ = {}
      for _0, key_val in ipairs(raw_options) do
        local k_17_, v_18_ = nil, nil
        do
          local _9_, _10_ = string.match(key_val, "([^=]+)=([^=]+)")
          if ((nil ~= _9_) and (nil ~= _10_)) then
            local key = _9_
            local value = _10_
            k_17_, v_18_ = key, value
          else
            local _1 = _9_
            k_17_, v_18_ = error(fmt("provider options must be given as key=value, got %q", key_val))
          end
        end
        if ((k_17_ ~= nil) and (v_18_ ~= nil)) then
          tbl_16_[k_17_] = v_18_
        else
        end
      end
      return tbl_16_
    end
  end
  local function parse_argv(argv0)
    if ((_G.type(argv0) == "table") and (argv0[1] == nil)) then
      return {["provider-name"] = nil, ["provider-options"] = nil, action = "create"}
    else
      local and_14_ = ((_G.type(argv0) == "table") and (nil ~= argv0[1]) and (argv0[2] == nil))
      if and_14_ then
        local provider_name = argv0[1]
        and_14_ = provider_syntax_3f(provider_name)
      end
      if and_14_ then
        local provider_name = argv0[1]
        return {["provider-name"] = string.sub(provider_name, 2), ["provider-options"] = nil, action = "create"}
      else
        local and_16_ = ((_G.type(argv0) == "table") and (nil ~= argv0[1]) and (nil ~= argv0[2]))
        if and_16_ then
          local provider_name = argv0[1]
          local action = argv0[2]
          local args = {select(3, (table.unpack or _G.unpack)(argv0))}
          and_16_ = provider_syntax_3f(provider_name)
        end
        if and_16_ then
          local provider_name = argv0[1]
          local action = argv0[2]
          local args = {select(3, (table.unpack or _G.unpack)(argv0))}
          return {["provider-name"] = string.sub(provider_name, 2), ["provider-options"] = parse_provider_options(args), action = action}
        elseif ((_G.type(argv0) == "table") and (nil ~= argv0[1])) then
          local action = argv0[1]
          local args = {select(2, (table.unpack or _G.unpack)(argv0))}
          return {["provider-name"] = nil, ["provider-options"] = parse_provider_options(args), action = action}
        else
          return nil
        end
      end
    end
  end
  local function handle_create_result(url, err)
    local _19_, _20_ = url, err
    if ((_19_ == nil) and (nil ~= _20_)) then
      local err0 = _20_
      return error(fmt("paperplanes got no url back from provider: %s", err0))
    elseif ((nil ~= _19_) and true) then
      local url0 = _19_
      local _ = _20_
      local reg = get_config_option("register")
      local msg_prefix
      if reg then
        msg_prefix = fmt("\"%s = ", reg)
      else
        msg_prefix = ""
      end
      local msg = fmt("%s%s", msg_prefix, url0)
      if reg then
        vim.fn.setreg(reg, url0)
      else
      end
      return notify(msg)
    else
      return nil
    end
  end
  local function handle_delete_result(url, err)
    local _24_, _25_ = url, err
    if ((_24_ == nil) and (nil ~= _25_)) then
      local err0 = _25_
      return error(fmt("paperplanes got an error from provider: %s", err0))
    elseif ((nil ~= _24_) and true) then
      local url0 = _24_
      local _ = _25_
      local msg = fmt("deleted %s", url0)
      return notify(msg)
    else
      return nil
    end
  end
  local buf_id = vim.api.nvim_get_current_buf()
  local unique_id = ("buffer-" .. buf_id)
  local use_marks_3f = (range_enum == 2)
  local _let_27_ = create_text_range(buf_id, use_marks_3f)
  local _let_28_ = _let_27_[1]
  local start_row = _let_28_[1]
  local start_col = _let_28_[2]
  local _let_29_ = _let_27_[2]
  local end_row = _let_29_[1]
  local end_col = _let_29_[2]
  local content_string = table.concat(vim.api.nvim_buf_get_text(buf_id, start_row, start_col, end_row, end_col, {}), "\n")
  local content_meta
  local function _30_()
    return {path = vim.fn.expand("%:p"), filename = vim.fn.expand("%:t"), extension = vim.fn.expand("%:e"), filetype = vim.bo.filetype}
  end
  content_meta = vim.api.nvim_buf_call(buf_id, _30_)
  local _let_31_ = parse_argv(argv)
  local provider_name = _let_31_["provider-name"]
  local provider_options = _let_31_["provider-options"]
  local action = _let_31_["action"]
  notify(fmt("%s'ing...", (provider_name or get_config_option("provider"))))
  if (action == "create") then
    return create(unique_id, content_string, content_meta, handle_create_result, provider_name, provider_options)
  elseif (action == "update") then
    return update(unique_id, content_string, content_meta, handle_create_result, provider_name, provider_options)
  elseif (action == "delete") then
    return delete(unique_id, handle_delete_result, provider_name, provider_options)
  else
    local _ = action
    return error(fmt("Action must be create, update or delete, got %q", action))
  end
end
local function complete(arg_lead, cmd_line, cursor_pos)
  local function filter(options, prefix, do_not_return_default_all_3f)
    local filtered
    local function _33_(_241)
      return vim.startswith(_241, prefix)
    end
    filtered = vim.tbl_filter(_33_, options)
    local _34_ = #filtered
    if (_34_ == 0) then
      if do_not_return_default_all_3f then
        return {}
      else
        return options
      end
    else
      local _ = _34_
      return filtered
    end
  end
  local function get_provider(provider_name)
    local providers = require("paperplanes.providers")
    local provider_name0 = ((provider_name and string.sub(provider_name, 2)) or get_config_option("provider"))
    return providers[provider_name0]
  end
  local function complete_provider(arg_lead0)
    local _37_
    do
      local tbl_21_ = {}
      local i_22_ = 0
      for name, _ in pairs(require("paperplanes.providers")) do
        local val_23_ = ("@" .. name)
        if (nil ~= val_23_) then
          i_22_ = (i_22_ + 1)
          tbl_21_[i_22_] = val_23_
        else
        end
      end
      _37_ = tbl_21_
    end
    return filter(_37_, arg_lead0)
  end
  local function complete_action(provider_name, arg_lead0)
    local function _39_(...)
      local _40_ = ...
      if ((_G.type(_40_) == "table") and (nil ~= _40_.completions)) then
        local completions = _40_.completions
        return filter(vim.tbl_keys(completions()), arg_lead0)
      else
        local _ = _40_
        return {}
      end
    end
    return _39_(get_provider(provider_name))
  end
  local function complete_provider_arguments(provider_name, action, _arguments, arg_lead0)
    local function _42_(...)
      local _43_ = ...
      if ((_G.type(_43_) == "table") and (nil ~= _43_.completions)) then
        local completions = _43_.completions
        local function _44_(...)
          local _45_ = ...
          if (nil ~= _45_) then
            local action_completions = _45_
            return filter(action_completions, arg_lead0)
          else
            local _ = _45_
            return {}
          end
        end
        return _44_(completions()[action])
      else
        local _ = _43_
        return {}
      end
    end
    return _42_(get_provider(provider_name))
  end
  local arguments = vim.split(string.gsub(cmd_line, "%s+", " "), " ", {trimempty = false})
  local and_48_ = ((_G.type(arguments) == "table") and true and (nil ~= arguments[2]) and (arguments[3] == nil))
  if and_48_ then
    local _PP = arguments[1]
    local provider = arguments[2]
    and_48_ = provider_syntax_3f(provider)
  end
  if and_48_ then
    local _PP = arguments[1]
    local provider = arguments[2]
    return complete_provider(provider)
  elseif ((_G.type(arguments) == "table") and true and (nil ~= arguments[2]) and (arguments[3] == nil)) then
    local _PP = arguments[1]
    local action = arguments[2]
    return complete_action(nil, action)
  else
    local and_50_ = ((_G.type(arguments) == "table") and true and (nil ~= arguments[2]) and (nil ~= arguments[3]) and (arguments[4] == nil))
    if and_50_ then
      local _PP = arguments[1]
      local provider = arguments[2]
      local action = arguments[3]
      and_50_ = provider_syntax_3f(provider)
    end
    if and_50_ then
      local _PP = arguments[1]
      local provider = arguments[2]
      local action = arguments[3]
      return complete_action(provider, action)
    else
      local and_52_ = ((_G.type(arguments) == "table") and true and (nil ~= arguments[2]) and (nil ~= arguments[3]))
      if and_52_ then
        local _PP = arguments[1]
        local provider = arguments[2]
        local action = arguments[3]
        local arguments0 = {select(4, (table.unpack or _G.unpack)(arguments))}
        and_52_ = provider_syntax_3f(provider)
      end
      if and_52_ then
        local _PP = arguments[1]
        local provider = arguments[2]
        local action = arguments[3]
        local arguments0 = {select(4, (table.unpack or _G.unpack)(arguments))}
        return complete_provider_arguments(provider, action, arguments0, arg_lead)
      elseif ((_G.type(arguments) == "table") and true and (nil ~= arguments[2])) then
        local _PP = arguments[1]
        local action = arguments[2]
        local arguments0 = {select(3, (table.unpack or _G.unpack)(arguments))}
        return complete_provider_arguments(nil, action, arguments0, arg_lead)
      else
        local _ = arguments
        return {}
      end
    end
  end
end
local function install()
  local args = {force = true, range = "%", complete = complete, nargs = "*", desc = "Pastebin selected text or entire buffer via paperplanes.nvim, see :h paperplanes-command."}
  vim.api.nvim_create_user_command("Paperplanes", run_command, args)
  return vim.api.nvim_create_user_command("PP", run_command, args)
end
return {install = install}