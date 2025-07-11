local fmt = string.format
local uv = (vim.uv or vim.loop)
local function assert_hut()
  return assert((vim.fn.executable("hut") == 1), fmt("paperplanes.nvim could not find %q executable", "hut"))
end
local function completions()
  return {create = {"visibility=unlisted", "visibility=public", "visibility=private"}, delete = {}}
end
local function create(content, metadata, options, on_complete)
  assert_hut()
  local _let_1_ = require("paperplanes.exec")
  local exec = _let_1_["exec"]
  local paste_visiblity = (options.visibility or "unlisted")
  local filename = (metadata.filename or "paste.txt")
  local on_exit
  local function _2_(exit_code, stdout, stderr)
    if (exit_code == 0) then
      local url = string.match(stdout, "(.+)\n")
      local id = string.match(url, ".+/(.+)")
      return on_complete(url, {id = id})
    else
      local _ = exit_code
      return on_complete(nil, stderr)
    end
  end
  on_exit = _2_
  local on_spawn
  local function _5_(_4_)
    local stdin = _4_["stdin"]
    return uv.write(stdin, content)
  end
  on_spawn = _5_
  return exec("hut", {"paste", "create", "--visibility", paste_visiblity, "--name", filename}, on_exit, on_spawn)
end
local function delete(context, options, on_complete)
  assert_hut()
  local url = context[1]
  local _let_6_ = context[2]
  local id = _let_6_["id"]
  if id then
    local _let_7_ = require("paperplanes.exec")
    local exec = _let_7_["exec"]
    local on_exit
    local function _8_(status, stdout, stderr)
      if (status == 0) then
        return on_complete(url, {})
      else
        local _ = status
        return on_complete(nil, stderr)
      end
    end
    on_exit = _8_
    return exec("hut", {"paste", "delete", id}, on_exit)
  else
    local msg = fmt("No id recorded for %s, unable to delete.", url)
    return on_complete(nil, msg)
  end
end
return {create = create, delete = delete, completions = completions}