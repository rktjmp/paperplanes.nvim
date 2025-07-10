local fmt = string.format
local function encode(content)
  local function transpose(i)
    local enc_map = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"}
    return enc_map[(1 + i)]
  end
  local function three_wide__3efour_wide(three_char_wide_string)
    local a, b, c = string.byte(three_char_wide_string, 1, 3)
    return (transpose(bit.rshift(a, 2)) .. transpose(bit.bor(bit.lshift(bit.band(a, 3), 4), bit.rshift(b, 4))) .. transpose(bit.bor(bit.lshift(bit.band(b, 15), 2), bit.rshift(c, 6))) .. transpose(bit.band(c, 63)))
  end
  local padding = ((((#content - 1) % 3) * -1) + 2)
  local unpadded = string.gsub((content .. string.rep("\0", padding)), "...", three_wide__3efour_wide)
  local padded = (string.sub(unpadded, 1, (#unpadded - padding)) .. string.rep("=", padding))
  return padded
end
local function completions()
  return {create = {"title=", "padding=64", "language=auto", "darkmode=false", "colors=midnight", "background=true"}}
end
local function create(content, metadata, opts, on_complete)
  local default_opts = {padding = 64, language = "auto", colors = "midnight", background = true, darkmode = false}
  local encoded = encode(content)
  local url = fmt("https://ray.so#title=%s&padding=%d&theme=%s&language=%s&background=%s&darkMode=%s&code=%s", (opts.title or metadata.filename or "paste.txt"), (opts.padding or default_opts.padding), (opts.colors or default_opts.colors), (opts.language or default_opts.language), (opts.background or default_opts.background), (opts.darkmode or default_opts.darkmode), encoded)
  return on_complete(url, {})
end
return {create = create, completions = completions}