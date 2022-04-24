# _paperplanes_.nvim

![paperplanes Logo](images/logo.png)

Post selections or buffers to online paste bins. Save the URL to a register, or
dont.

## Requirements

- Neovim 0.5+
- An `curl` executable in your `$PATH`

## Install

Use your package manager.

## Configuration & Use

**Setup**

```lua
-- options shown with default values
require("paperplanes").setup({
  register = "+",
  provider = "0x0.st",
  provider_options = {},
  cmd = "curl"
})
```

- `register` - any valid register name or false
- `provider` - "0x0.st", "ix.io", "dpaste.org", "sprunge.us" or "paste.rs"
- `provider_options` - passed to selected provider, check provider to know if
                       you need to use this option. Not all providers are option
                       aware.
- `cmd` - curl-compatible executable

**Commands**

Post selection or buffer to configured provider, sets configured register and
print's the result.

- `:PP` -> Post current buffer.

- `:[range]PP` -> Post range.
  - Vim does not support column aware ranges when using commands. Use
    `post_selection` via a map for that behaviour.

**Functions**

See [`:h paperplanes`](doc/paperplanes.txt).

Functions are provided in `snake_case` and `kebab-case`.

All functions accept a `callback` argument which is called with `url, nil` or
`nil, errors`.

Functions to not automatically print the url or set any registers.

- `post_string(string, meta, callback)`
  - where `meta` is a table containing `path`, `filename`, `extension` and
    `filetype` values if possible.
- `post_range(buffer, start_pos, end_pos, callback)`
  - where positions can be `line` or `[line, col]`
- `post_selection(callback)`
- `post_buffer(buffer, callback)`

## Providers

_paperplanes_ supports the following providers, see sites for TOS and
features.

- http://0x0.st
- http://ix.io
- http://dpaste.org
- http://sprunge.us
- https://paste.rs

To create a new provider, see [`:h paperplanes`](doc/paperplanes.txt) and
`fnl/paperplanes/providers/*.fnl`.

_paperplanes_ is not affiliated with any provider in any manner.

## Building

_paperplanes_ includes a basic build system. It requires
[hotpot.nvim](https://github.com/rktjmp/hotpot.nvim) to run.

1. Open `build.fnl`
2. Run `:Fnl`
