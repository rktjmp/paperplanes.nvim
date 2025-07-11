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
  local function parse_argv(argv0)
    if ((_G.type(argv0) == "table") and (argv0[1] == nil)) then
      return {["provider-name"] = nil, ["provider-options"] = {}, action = "create"}
    else
      local and_9_ = ((_G.type(argv0) == "table") and (nil ~= argv0[1]) and (argv0[2] == nil))
      if and_9_ then
        local provider_name = argv0[1]
        and_9_ = provider_syntax_3f(provider_name)
      end
      if and_9_ then
        local provider_name = argv0[1]
        return {["provider-name"] = string.sub(provider_name, 2), ["provider-options"] = {}, action = "create"}
      else
        local and_11_ = ((_G.type(argv0) == "table") and (nil ~= argv0[1]) and (nil ~= argv0[2]))
        if and_11_ then
          local provider_name = argv0[1]
          local action = argv0[2]
          local args = {select(3, (table.unpack or _G.unpack)(argv0))}
          and_11_ = provider_syntax_3f(provider_name)
        end
        if and_11_ then
          local provider_name = argv0[1]
          local action = argv0[2]
          local args = {select(3, (table.unpack or _G.unpack)(argv0))}
          return {["provider-name"] = string.sub(provider_name, 2), ["provider-options"] = args, action = action}
        elseif ((_G.type(argv0) == "table") and (nil ~= argv0[1])) then
          local action = argv0[1]
          local args = {select(2, (table.unpack or _G.unpack)(argv0))}
          return {["provider-name"] = nil, ["provider-options"] = args, action = action}
        else
          return nil
        end
      end
    end
  end
  local function parse_provider_options(raw_options)
    local tbl_16_ = {}
    for _, key_val in ipairs(raw_options) do
      local k_17_, v_18_ = nil, nil
      do
        local _14_, _15_ = string.match(key_val, "([^=]+)=([^=]+)")
        if ((nil ~= _14_) and (nil ~= _15_)) then
          local key = _14_
          local value = _15_
          k_17_, v_18_ = key, value
        else
          local _0 = _14_
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
  local function handle_create_result(url, err)
    local _18_, _19_ = url, err
    if ((_18_ == nil) and (nil ~= _19_)) then
      local err0 = _19_
      return error(fmt("paperplanes got no url back from provider: %s", err0))
    elseif ((nil ~= _18_) and true) then
      local url0 = _18_
      local _ = _19_
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
    local _23_, _24_ = url, err
    if ((_23_ == nil) and (nil ~= _24_)) then
      local err0 = _24_
      return error(fmt("paperplanes got an error from provider: %s", err0))
    elseif ((nil ~= _23_) and true) then
      local url0 = _23_
      local _ = _24_
      local msg = fmt("deleted %s", url0)
      return notify(msg)
    else
      return nil
    end
  end
  local buf_id = vim.api.nvim_get_current_buf()
  local unique_id = ("buffer-" .. buf_id)
  local use_marks_3f = (range_enum == 2)
  local _let_26_ = create_text_range(buf_id, use_marks_3f)
  local _let_27_ = _let_26_[1]
  local start_row = _let_27_[1]
  local start_col = _let_27_[2]
  local _let_28_ = _let_26_[2]
  local end_row = _let_28_[1]
  local end_col = _let_28_[2]
  local content_string = table.concat(vim.api.nvim_buf_get_text(buf_id, start_row, start_col, end_row, end_col, {}), "\n")
  local content_meta
  local function _29_()
    return {path = vim.fn.expand("%:p"), filename = vim.fn.expand("%:t"), extension = vim.fn.expand("%:e"), filetype = vim.bo.filetype}
  end
  content_meta = vim.api.nvim_buf_call(buf_id, _29_)
  local _let_30_ = parse_argv(argv)
  local provider_name = _let_30_["provider-name"]
  local provider_options = _let_30_["provider-options"]
  local action = _let_30_["action"]
  local default_provider_name = get_config_option("provider")
  local parsed_options
  do
    local _31_ = parse_provider_options(provider_options)
    if ((_G.type(_31_) == "table") and (_31_[1] == nil)) then
      parsed_options = nil
    elseif (nil ~= _31_) then
      local opts = _31_
      parsed_options = opts
    else
      parsed_options = nil
    end
  end
  notify(fmt("%s'ing...", (provider_name or default_provider_name)))
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
    local function _34_(_241)
      return vim.startswith(_241, prefix)
    end
    filtered = vim.tbl_filter(_34_, options)
    local _35_ = #filtered
    if (_35_ == 0) then
      if do_not_return_default_all_3f then
        return {}
      else
        return options
      end
    else
      local _ = _35_
      return filtered
    end
  end
  local function get_provider(provider_name)
    local providers = require("paperplanes.providers")
    local provider_name0 = ((provider_name and string.sub(provider_name, 2)) or get_config_option("provider"))
    return providers[provider_name0]
  end
  local function complete_provider(arg_lead0)
    local _38_
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
      _38_ = tbl_21_
    end
    return filter(_38_, arg_lead0)
  end
  local function complete_action(provider_name, arg_lead0)
    local function _40_(...)
      local _41_ = ...
      if ((_G.type(_41_) == "table") and (nil ~= _41_.completions)) then
        local completions = _41_.completions
        return filter(vim.tbl_keys(completions()), arg_lead0)
      else
        local _ = _41_
        return {}
      end
    end
    return _40_(get_provider(provider_name))
  end
  local function complete_provider_arguments(provider_name, action, _arguments, arg_lead0)
    local function _43_(...)
      local _44_ = ...
      if ((_G.type(_44_) == "table") and (nil ~= _44_.completions)) then
        local completions = _44_.completions
        local function _45_(...)
          local _46_ = ...
          if (nil ~= _46_) then
            local action_completions = _46_
            return filter(action_completions, arg_lead0)
          else
            local _ = _46_
            return {}
          end
        end
        return _45_(completions()[action])
      else
        local _ = _44_
        return {}
      end
    end
    return _43_(get_provider(provider_name))
  end
  local arguments = vim.split(string.gsub(cmd_line, "%s+", " "), " ", {trimempty = false})
  local and_49_ = ((_G.type(arguments) == "table") and true and (nil ~= arguments[2]) and (arguments[3] == nil))
  if and_49_ then
    local _PP = arguments[1]
    local provider = arguments[2]
    and_49_ = provider_syntax_3f(provider)
  end
  if and_49_ then
    local _PP = arguments[1]
    local provider = arguments[2]
    return complete_provider(provider)
  elseif ((_G.type(arguments) == "table") and true and (nil ~= arguments[2]) and (arguments[3] == nil)) then
    local _PP = arguments[1]
    local action = arguments[2]
    return complete_action(nil, action)
  else
    local and_51_ = ((_G.type(arguments) == "table") and true and (nil ~= arguments[2]) and (nil ~= arguments[3]) and (arguments[4] == nil))
    if and_51_ then
      local _PP = arguments[1]
      local provider = arguments[2]
      local action = arguments[3]
      and_51_ = provider_syntax_3f(provider)
    end
    if and_51_ then
      local _PP = arguments[1]
      local provider = arguments[2]
      local action = arguments[3]
      return complete_action(provider, action)
    else
      local and_53_ = ((_G.type(arguments) == "table") and true and (nil ~= arguments[2]) and (nil ~= arguments[3]))
      if and_53_ then
        local _PP = arguments[1]
        local provider = arguments[2]
        local action = arguments[3]
        local arguments0 = {select(4, (table.unpack or _G.unpack)(arguments))}
        and_53_ = provider_syntax_3f(provider)
      end
      if and_53_ then
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