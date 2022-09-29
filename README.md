# _paperplanes_.nvim

![paperplanes Logo](images/logo.png)

Post selections or buffers to online paste bins. Save the URL to a register, or
dont.

## Requirements

- Neovim 0.5+
- A `curl` executable in your `$PATH`

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
  notifier = vim.notify or print,
})
```

- `register` - any valid register name or false
- `provider` - See provider list.
- `provider_options` - passed to selected provider, check provider code for
  accepted options.
- `notifier` - any function that accepts a string, should show that string in some way.

**Commands**

Post selection or buffer to configured provider, sets configured register and
print's the result.

- `:PP` -> Post current buffer.

- `:[range]PP` -> Post range.
  - Vim does not support column aware ranges when using commands. Use
    `post_selection` via a map for that behaviour.

**Functions**

See [`:h paperplanes`](doc/paperplanes.txt) for more complete documentation.

Functions are provided in `snake_case` and `kebab-case` (`post_string` and
`post-string`).

All functions accept a `callback` argument which is called with `url, nil` or
`nil, errors`.

`provider-name` and `provider-options` are optional and the default provider
will be used if not given.

Functions to not automatically print the url or set any registers.

- `post_string(content, metadata, callback, provider-name, provider-options)`
- `post_range(buffer, start_pos, end_pos, callback, provider-name, provider-options)`
- `post_selection(callback, provider-name, provider-options)`
- `post_buffer(buffer, callback, provider-name, provider-options)`

## Providers

_paperplanes_ supports the following providers, see sites for TOS and
features.

- https://0x0.st (`provider = "0x0.st"`)
- https://paste.rs (`provider = "paste.rs"`)
- https://paste.sr.ht (`provider = "sr.ht"`)
- https://dpaste.org (`provider = "dpaste.org"`)
- https://ray.so (`provider = "ray.so"`)
- https://mystb.in (`provider = "mystb.in"`)
- http://ix.io (`provider = "ix.io"`)
  - **Endpoint is HTTP only**, requires `insecure = true` explicit opt in.
- http://sprunge.us (`provider = "sprunge.us"`)
  - **Endpoint is HTTP only**, requires `insecure = true` explicit opt in.

To create a new provider, see [`:h paperplanes`](doc/paperplanes.txt) and
`fnl/paperplanes/providers/*.fnl`.

_paperplanes_ is not affiliated with any provider in any manner.

## Building

Building _paperplanes_ requires [hotpot.nvim](https://github.com/rktjmp/hotpot.nvim).

1. Run `:Fnlfile make.fnl` when your `cwd` is `paperplanes.nvim`.

or

1. Remove `rm -rf lua/` and Hotpot will automatically compile when you reload neovim.

*Note: `lua/` is `.gitignore`'d for my own QOL (so those files dont appear in
file pickers), it's preferred to submit PRs without updated lua files.*

## Changelog

See `CHANGELOG.md`.
