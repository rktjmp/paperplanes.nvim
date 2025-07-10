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
  save_history = true
})
```

- `register` - any valid register name or false
- `provider` - See provider list.
- `provider_options` - passed to selected provider, see list of providers below for accepted options
- `notifier` - any function that accepts a string, should show that string in some way.
- `save_history` - record actions to history log when true

**Commands**

Create a paste of the current buffer, to the configured provider.

```vim
:PP
```

Create a paste of the current selection, to the configured provider. (Available
by selecting some text in visual mode and pressing `:`.)

```vim
:'<,'>PP
```

The `PP` command supports more complex usage, where you may specify the
provider, action and action arguments on the command line.

```vim
:PP [@<provider>] [action] [key=value ...]
```

- `@<provider>`: (optional) Override the default provider.
  - See tab-completion for known providers, ex: `@0x0.st`.
- `action`:
  - `create`: (default) Create a paste using the content of the current buffer or visual selection.
  - `update`: Update a paste using the content of the current buffer or visual selection.
    - Not all providers support updating, use tab-completion for available actions.
    - Updating pastes is only possible to do from the same instance of neovim
      that created the paste.
  - `delete`: Delete a paste associated with the current buffer.
    - Not all providers support deletion, use tab-completion for available actions.
    - Deleting pastes is only possible to do from the same instance of neovim
      that created the paste. You man review the history file
      (`require("paperplanes").history_path()`) for tokens required to manually
      delete an historic paste from a provider.
- `key=value`: (optional) Supply arguments to a provider.
  - You must provide an action when supplying arguments.
  - See tab-completion for known arguments, though any given will be passed on
  to the best of paperplanes ability, see your providers documentaion.
  - You may also override default `provider_options`.

**History**

A record of all actions performed is stored in a JSON file, located at
`require("paperplanes").history_path()` for review or manual operations.

History can be disabled via the `save_history` option.

Note that the history file may contain pseudo-sensitive content such as
deletion tokens returned from some providers. It does not record authorization
tokens required by some providers such as github or sourcehut.

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
  - `expires`: hours or unix-epoch.
  - `secret`: generate longer urls.
- https://paste.rs (`provider = "paste.rs"`)
- https://paste.sr.ht (`provider = "sr.ht"`)
  - `command`: `"curl"` (default) or `"hut"`.
  - `token`: PAT token string, or function returning token string, required if `command = "curl" | nil`.
- https://gist.github.com (`provider = "gist"`)
  - `command`: `"curl"` (default) or `"gh"`.
  - `token`: PAT token string or function returning token string, required if `command = "curl" | nil`.
- https://dpaste.org (`provider = "dpaste.org"`)
- https://ray.so (`provider = "ray.so"`)
  - `padding`
  - `colors`
  - `darkmode`
  - `background`
  - See ray.so for values.
- https://mystb.in (`provider = "mystb.in"`)
  - `secret`: password

To create a new provider, see [`:h paperplanes`](doc/paperplanes.txt) and
`fnl/paperplanes/providers/*.fnl`.

_paperplanes_ is not affiliated with any provider in any manner.

## Building

Building _paperplanes_ requires [hotpot.nvim](https://github.com/rktjmp/hotpot.nvim) v0.9.7+.

The relevant `lua|` files should be build when saving any file inside `fnl/`.

## Changelog

See `CHANGELOG.md`.
