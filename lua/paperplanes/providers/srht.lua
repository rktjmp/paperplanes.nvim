local fmt = string.format
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
  local temp_dir = vim.uv.fs_mkdtemp(vim.fs.joinpath(vim.fn.stdpath("run"), "paperplanes_hut_XXXXXX"))
  local temp_filename = (metadata.filename or "paste.txt")
  local temp_path = vim.fs.joinpath(temp_dir, temp_filename)
  local _
  do
    local outfile = io.open(temp_path, "w")
    local function close_handlers_12_(ok_13_, ...)
      outfile:close()
      if ok_13_ then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _3_()
      return outfile:write(content)
    end
    local _5_
    do
      local t_4_ = _G
      if (nil ~= t_4_) then
        t_4_ = t_4_.package
      else
      end
      if (nil ~= t_4_) then
        t_4_ = t_4_.loaded
      else
      end
      if (nil ~= t_4_) then
        t_4_ = t_4_.fennel
      else
      end
      _5_ = t_4_
    end
    local or_9_ = _5_ or _G.debug
    if not or_9_ then
      local function _10_()
        return ""
      end
      or_9_ = {traceback = _10_}
    end
    _ = close_handlers_12_(_G.xpcall(_3_, or_9_.traceback))
  end
  local on_exit
  local function _11_(exit_code, stdout, stderr)
    vim.loop.fs_unlink(temp_path)
    if (exit_code == 0) then
      local url = string.match(stdout, "(.+)\n")
      local id = string.match(url, ".+/(.+)")
      return on_complete(url, {id = id})
    else
      local _0 = exit_code
      return on_complete(nil, stderr)
    end
  end
  on_exit = _11_
  return exec("hut", {"paste", "create", "--visibility", paste_visiblity, temp_path}, on_exit)
end
local function delete(context, options, on_complete)
  assert_hut()
  local url = context[1]
  local _let_13_ = context[2]
  local id = _let_13_["id"]
  if id then
    local _let_14_ = require("paperplanes.exec")
    local exec = _let_14_["exec"]
    local on_exit
    local function _15_(status, stdout, stderr)
      if (status == 0) then
        return on_complete(url, {})
      else
        local _ = status
        return on_complete(nil, stderr)
      end
    end
    on_exit = _15_
    return exec("hut", {"paste", "delete", id}, on_exit)
  else
    local msg = fmt("No id recorded for %s, unable to delete.", url)
    return on_complete(nil, msg)
  end
end
return {create = create, delete = delete, completions = completions}