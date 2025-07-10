local fmt = string.format
local function get_token(options)
  local function try_provided_token(_1_)
    local provided_token = _1_["token"]
    local _2_, _3_ = provided_token, type(provided_token)
    if ((_2_ == nil) and true) then
      local _ = _3_
      return nil
    elseif ((nil ~= _2_) and (_3_ == "string")) then
      local raw_token = _2_
      return raw_token
    elseif ((nil ~= _2_) and (_3_ == "function")) then
      local token_function = _2_
      return try_provided_token(token_function())
    elseif (true and (nil ~= _3_)) then
      local _ = _2_
      local t = _3_
      local msg = table.concat({"Unsupported auth token type: %s", "Must be string or function returning string"}, "\n")
      return error(fmt(msg, t))
    else
      return nil
    end
  end
  local function try_gh_cli()
    local _5_ = vim.fn.executable("gh")
    if (_5_ == 1) then
      local _6_ = vim.system({"gh", "auth", "token"}):wait()
      if ((_G.type(_6_) == "table") and (_6_.code == 0) and (nil ~= _6_.stdout)) then
        local stdout = _6_.stdout
        local _7_ = string.match(stdout, "(.+)\n")
        if (nil ~= _7_) then
          local token = _7_
          return token
        elseif (_7_ == nil) then
          return error("`gh auth token` returned output but was incorrectly formatted.")
        else
          return nil
        end
      elseif ((_G.type(_6_) == "table") and (nil ~= _6_.code) and (nil ~= _6_.stderr)) then
        local n = _6_.code
        local err = _6_.stderr
        return error(table.concat({"`gh auth token` returned an error: \n", "code: ", n, "\n", "message: ", err, "\n", "Either provide an auth token directly via the token option or", " correct the issue with the github cli."}, ""))
      else
        return nil
      end
    else
      local _ = _5_
      return nil
    end
  end
  local function _11_(...)
    local _12_ = ...
    if (_12_ == nil) then
      local function _13_(...)
        local _14_ = ...
        if (_14_ == nil) then
          return error(table.concat({"No auth token found, either provide one directly via the `token` option", "or ensure that the github cli is installed and authenticated."}, " "))
        elseif (nil ~= _14_) then
          local token = _14_
          return token
        else
          return nil
        end
      end
      return _13_(try_gh_cli())
    elseif (nil ~= _12_) then
      local token = _12_
      return token
    else
      return nil
    end
  end
  return _11_(try_provided_token(options))
end
local function completions()
  return {create = {"description=", "public=true", "token="}, update = {"description=", "token="}, delete = {"token="}}
end
local function create(content, metadata, options, on_complete)
  local curl = require("paperplanes.curl")
  local token = get_token(options)
  local filename = (metadata.filename or "paste.txt")
  local payload
  local _18_
  do
    local _17_ = options.public
    if (_17_ == nil) then
      _18_ = false
    elseif (nil ~= _17_) then
      local val = _17_
      _18_ = val
    else
      _18_ = nil
    end
  end
  payload = {files = {[filename] = {content = content}}, description = options.description, public = _18_}
  local args = {"-L", "-X", "POST", "--header", fmt("Authorization: Bearer %s", token), "--header", "Accept: application/vnd.github+json", "--header", "X-Github-Api-Version: 2022-11-28", "--data-binary", vim.json.encode(payload)}
  local response_handler
  local function _23_(_22_)
    local response = _22_["response"]
    local status = _22_["status"]
    local headers = _22_["headers"]
    if (status == 201) then
      local _let_24_ = vim.json.decode(response)
      local html_url = _let_24_["html_url"]
      local id = _let_24_["id"]
      return on_complete(html_url, {id = id, filename = filename})
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  response_handler = _23_
  return curl("https://api.github.com/gists", args, response_handler)
end
local function update(context, content, metadata, options, on_complete)
  local original_url = context[1]
  local _let_26_ = context[2]
  local id = _let_26_["id"]
  local filename = _let_26_["filename"]
  if id then
    local curl = require("paperplanes.curl")
    local token = get_token(options)
    local payload = {files = {[filename] = {content = content}}, description = options.description}
    local args = {"-L", "-X", "PATCH", "--header", fmt("Authorization: Bearer %s", token), "--header", "Accept: application/vnd.github+json", "--header", "X-Github-Api-Version: 2022-11-28", "--data-binary", vim.json.encode(payload)}
    local url = fmt("https://api.github.com/gists/%s", id)
    local response_handler
    local function _28_(_27_)
      local response = _27_["response"]
      local status = _27_["status"]
      local headers = _27_["headers"]
      if (status == 200) then
        local _let_29_ = vim.json.decode(response)
        local html_url = _let_29_["html_url"]
        local id0 = _let_29_["id"]
        return on_complete(html_url, {id = id0, filename = filename})
      else
        local _ = status
        return on_complete(nil, response)
      end
    end
    response_handler = _28_
    return curl(url, args, response_handler)
  else
    local msg = fmt("No id recorded for %s, unable to update.", original_url)
    return on_complete(nil, msg)
  end
end
local function delete(context, options, on_complete)
  local original_url = context[1]
  local _let_32_ = context[2]
  local id = _let_32_["id"]
  if id then
    local curl = require("paperplanes.curl")
    local token = get_token(options)
    local args = {"-L", "-X", "DELETE", "--header", fmt("Authorization: Bearer %s", token), "--header", "Accept: application/vnd.github+json", "--header", "X-Github-Api-Version: 2022-11-28"}
    local url = fmt("https://api.github.com/gists/%s", id)
    local response_handler
    local function _34_(_33_)
      local response = _33_["response"]
      local status = _33_["status"]
      local headers = _33_["headers"]
      if (status == 204) then
        return on_complete(original_url, {})
      else
        local _ = status
        return on_complete(nil, response)
      end
    end
    response_handler = _34_
    return curl(url, args, response_handler)
  else
    local msg = fmt("No id recorded for %s, unable to delete.", original_url)
    return on_complete(nil, msg)
  end
end
return {completions = completions, create = create, update = update, delete = delete}