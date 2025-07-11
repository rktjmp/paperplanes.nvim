*1.0.1*

- Added luarocks github workflow, no user facing changes.

*1.0.0*

- Added support for updating & deleting pastes where provider supported.
- Added support for provider arguments such as expiry.
- Added advanced command support with run-time selection of provider, action
  and provider arguments.
- Added JSON history file for manual review & recovery.
- Added support to automatically find Github gist tokens without configuration.
- Removed sprunge.us and ix.io support (services are no longer available).
- Removed sourcehut `curl` command option, now requires use of `hut` cli tool.
  (Sourcehut no longer provides a `curl` compatible API.)

*0.1.6*

- Added gist support, via curl (default) or `gh`

*0.1.5*

- Fixed ray.so
- Added `hut` support for source hut provider.

*0.1.4*

- Fixed paste.rs

*0.1.3*

- Added mystb.in support

*0.1.2*

- Added ray.so support
- Function API able to use non-default provider and provider options

*0.1.1*

- Added sr.ht support
- Added provider-options support

*0.1.0*

Initial release
