local fmt = string.format
local function make(content_arg, meta, opts)
  assert(opts.token, "You must set provider_opts.token to your sr.ht token")
  local args = {"--header", fmt("Authorization:token %s", opts.token), "--header", "Content-Type:application/json", "https://paste.sr.ht/api/pastes", "--data-binary", fmt("%s", vim.json.encode({visibility = (opts.visibility or "unlisted"), files = {{filename = vim.fn.expand("%:t"), contents = content_arg}}}))}
  local function after(response, status)
    local _1_ = status
    if (_1_ == 201) then
      local response0 = vim.json.decode(response)
      return fmt("https://paste.sr.ht/%s/%s", response0.user.canonical_name, response0.sha)
    elseif true then
      local _ = _1_
      return nil, response
    else
      return nil
    end
  end
  return args, after
end
local function post_string(string, meta, opts)
  return make(string, meta, opts)
end
return {["post-string"] = post_string}