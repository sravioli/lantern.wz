# lantern.wz Contributing Guide

Welcome to the Lantern contributing guide.

Lantern is a WezTerm plugin for configurable selection workflows. The core
concepts are:

- **Wicks**: named selectable collections.
- **Flames**: modules or inline tables that expose choices with `glow()`.
- **Ignition**: applying a selected choice with `ignite(config, ctx)`.

## Contribution Types

We accept:

- source changes for wicks, flames, persistence, formatting, or API behavior;
- tests under `spec/`;
- documentation updates for the README, issue templates, and examples;
- reproducible bug reports through the issue templates.

We do not currently accept translations or outreach-only contributions.

## Environment Setup

1. Fork and clone the repository:

   ```sh
   git clone https://github.com/<your-username>/lantern.wz.git
   cd lantern.wz
   ```

2. Install the local tooling:

   ```sh
   luarocks install busted
   luarocks install luacov
   luarocks install luacheck
   ```

   Install [StyLua](https://github.com/JohnnyMorganz/StyLua) and
   [Selene](https://kampfkarren.github.io/selene/) separately.

3. Test a local checkout from WezTerm:

   ```lua
   local lantern = wezterm.plugin.require(
     "file:///" .. wezterm.config_dir .. "/plugins/lantern.wz"
   )
   ```

## Local Checks

Run these before opening a pull request:

```sh
busted --verbose
stylua --check .
selene .
luacheck .
```

## Best Practices

- Keep commits focused on one concern.
- Use Conventional Commit messages, for example `fix(state): migrate legacy
  paths` or `feat(flames): add cached discovery`.
- Add or update Busted tests when changing public behavior.
- Preserve backward-compatible defaults unless a breaking change is intentional
  and documented.
- Keep public API terms consistent: `lantern`, `wick`, `flame`, `glow`,
  `ignite`, and `rekindle`.

## Pull Requests

1. Create a descriptive branch from `main`.
2. Make the smallest coherent change.
3. Run the local checks.
4. Open a pull request against
   [sravioli/lantern.wz](https://github.com/sravioli/lantern.wz).
5. Describe the behavior change, tests run, and any migration notes.

## Releases

Releases are automated through Cocogitto and GitHub Actions. Contributors do not
need to publish releases manually.

## Licensing

Code contributions are licensed under the [GNU General Public License
v2](../LICENSE). Documentation contributions are licensed under [Creative
Commons Attribution-NonCommercial 4.0 International](../LICENSE-DOCS).
