local fmt = string.format
local function via_hut(content, metadata, opts, on_complete)
  assert((vim.fn.executable("hut") == 1), fmt("paperplanes.nvim could not find %q executable", "hut"))
  local _let_1_ = require("paperplanes.exec")
  local exec = _let_1_["exec"]
  local temp_filename = string.format("%s-%s.%s", vim.fn.tempname(), (metadata.filename or "paste"), (metadata.extension or "txt"))
  local _
  do
    local outfile = io.open(temp_filename, "w")
    local function close_handlers_10_auto(ok_11_auto, ...)
      outfile:close()
      if ok_11_auto then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _3_()
      return outfile:write(content)
    end
    _ = close_handlers_10_auto(_G.xpcall(_3_, (package.loaded.fennel or debug).traceback))
  end
  local on_exit
  local function _4_(exit_code, output, errors)
    vim.loop.fs_unlink(temp_filename)
    if (exit_code == 0) then
      return on_complete(output)
    else
      local _0 = exit_code
      return on_complete(nil, (output .. " " .. errors))
    end
  end
  on_exit = _4_
  return exec("hut", {"paste", "create", temp_filename}, on_exit)
end
local function via_curl(content, metadata, opts, on_complete)
  assert(opts.token, "You must set provider_options.token to your sr.ht token")
  local curl = require("paperplanes.curl")
  local encoded = vim.json.encode({visibility = (opts.visibility or "unlisted"), files = {{filename = metadata.filename, contents = content}}})
  local token
  do
    local _6_ = type(opts.token)
    if (_6_ == "function") then
      token = opts.token()
    elseif (_6_ == "string") then
      token = opts.token
    elseif (nil ~= _6_) then
      local t = _6_
      token = error(fmt("unsupported token type: %s, must be string or function returning string", t))
    else
      token = nil
    end
  end
  local args = {"--header", fmt("Authorization:token %s", token), "--header", "Content-Type:application/json", "https://paste.sr.ht/api/pastes", "--data-binary", encoded}
  local resp_handler
  local function _8_(response, status)
    if (status == 201) then
      local response0 = vim.json.decode(response)
      local url = fmt("https://paste.sr.ht/%s/%s", response0.user.canonical_name, response0.sha)
      return on_complete(url)
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  resp_handler = _8_
  return curl(args, resp_handler)
end
local function provide(content, metadata, opts, on_complete)
  local _10_ = opts.command
  if (_10_ == "hut") then
    return via_hut(content, metadata, opts, on_complete)
  elseif ((_10_ == "curl") or true) then
    return via_curl(content, metadata, opts, on_complete)
  else
    return nil
  end
end
return provide