local _local_1_ = require("paperplanes.fn")
local reduce = _local_1_["reduce"]
local list_put = _local_1_["list-put"]
local list_append = _local_1_["list-append"]
local map_put = _local_1_["map-put"]
local fmt = string.format
local function filetype__3elexer(filetype)
  local known_filetypes = {"applescript", "arduino", "bash", "bat", "c", "clojure", "cmake", "coffee-script", "common-lisp", "console", "cpp", "cpp-objdump", "csharp", "css", "cuda", "d", "dart", "delphi", "diff", "django", "docker", "elixir", "erlang", "go", "handlebars", "haskell", "html", "html+django", "ini", "ipythonconsole", "irc", "java", "js", "json", "jsx", "kotlin", "less", "lua", "make", "matlab", "nginx", "numpy", "objective-c", "perl", "php", "postgresql", "python", "rb", "rst", "rust", "sass", "scss", "sol", "sql", "swift", "tex", "typoscript", "vim", "xml", "xslt", "yaml"}
  local matched = nil
  for _, kt in ipairs(known_filetypes) do
    if (nil ~= matched) then break end
    if (kt == filetype) then
      matched = kt
    else
      matched = nil
    end
  end
  return matched
end
local function provide(content, metadata, opts, on_complete)
  local curl = require("paperplanes.curl")
  local temp_filename = vim.fn.tempname()
  local defaults = {format = "default", lexer = filetype__3elexer(metadata.filetype), filename = metadata.filename}
  local args
  local function _3_(_241, _242, _243)
    return map_put(_243, _241, _242)
  end
  local function _4_(_241, _242, _243)
    return list_append(_243, {"--data-urlencode", fmt("%s=%s", _241, _242)})
  end
  args = list_put(list_append(reduce(reduce(opts, defaults, _3_), {}, _4_), {"--data-urlencode", fmt("content@%s", temp_filename)}), "https://dpaste.org/api/")
  local _ = print(vim.inspect(defaults))
  local resp_handler
  local function _5_(response, status)
    vim.loop.fs_unlink(temp_filename)
    if (status == 200) then
      return on_complete(string.match(response, "\"(.*)\""))
    else
      local _0 = status
      return on_complete(nil, response)
    end
  end
  resp_handler = _5_
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
    local function _8_()
      return outfile:write(content)
    end
    close_handlers_10_auto(_G.xpcall(_8_, (package.loaded.fennel or debug).traceback))
  end
  return curl(args, resp_handler)
end
return provide