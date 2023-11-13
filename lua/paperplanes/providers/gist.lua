local fmt = string.format
local function via_gh(content, metadata, opts, on_complete)
  assert((vim.fn.executable("gh") == 1), fmt("paperplanes.nvim could not find %q executable", "gh"))
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
  return exec("gh", {"gist", "create", "--public", temp_filename}, on_exit)
end
local function via_curl(content, metadata, opts, on_complete)
  assert(opts.token, "You must set provider_options.token to your github gist token")
  local curl = require("paperplanes.curl")
  local encoded = vim.json.encode({public = true, files = {[metadata.filename] = {content = content}}})
  local args = {"-L", "-X", "POST", "--header", fmt("Authorization: Bearer %s", opts.token), "--header", "Accept: application/vnd.github+json", "--header", "X-Github-Api-Version: 2022-11-28", "https://api.github.com/gists", "--data-binary", encoded}
  local resp_handler
  local function _6_(response, status)
    print(response, status)
    if (status == 201) then
      local response0 = vim.json.decode(response)
      local url = response0.html_url
      return on_complete(url)
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  resp_handler = _6_
  return curl(args, resp_handler)
end
local function provide(content, metadata, opts, on_complete)
  local _8_ = opts.command
  if (_8_ == "gh") then
    return via_gh(content, metadata, opts, on_complete)
  elseif ((_8_ == "curl") or true) then
    return via_curl(content, metadata, opts, on_complete)
  else
    return nil
  end
end
return provide