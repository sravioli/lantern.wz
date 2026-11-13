# lantern.wz

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/michaelbrusegard/awesome-wezterm)
[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/lantern.wz/tests.yaml?style=flat-square&label=tests)](https://github.com/sravioli/lantern.wz/actions/workflows/tests.yaml)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/lantern.wz/lint.yaml?style=flat-square&label=lint)](https://github.com/sravioli/lantern.wz/actions/workflows/lint.yaml)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/lantern.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/lantern.wz)
[![Code license](https://img.shields.io/badge/code-GPL--2.0-blue?style=flat-square)](../LICENSE)
[![Docs license](https://img.shields.io/badge/docs-CC_BY--NC_4.0-blue?style=flat-square)](../LICENSE-DOCS)

Pick and remember appearance settings in [WezTerm](https://wezterm.org/).

Change colors, fonts, spacing, GPU adapters, or your own presets from a
selector. A **wick** is a named selector; a **flame** supplies choices with
`glow()` and applies one with `ignite(config, ctx)`.

[Quick start](#quick-start) · [Usage](#usage) · [Configuration](#configuration) · [API reference](#api-reference) · [Troubleshooting](#troubleshooting) · [Development](#development) · [License](#license)

## Quick start

### Requirements

Requires **[WezTerm nightly with launcher-label colors (2025-05-11) or newer](https://github.com/wezterm/wezterm/commit/4a32feaa7eccda9b35a3cf5967946ce0fdd31486)**
and Git for all bundled themes and persistence.
Stable [`20240127-113634-bbcac864`](https://wezterm.org/config/lua/keyassignment/InputSelector.html)
supports choices without nightly-only fields, with persistence disabled.
GPU selection needs [`front_end = "WebGpu"`](https://wezterm.org/config/lua/config/webgpu_preferred_adapter.html).

Automatically loads [log.wz](https://github.com/sravioli/log.wz),
[memo.wz](https://github.com/sravioli/memo.wz),
[ribbon.wz](https://github.com/sravioli/ribbon.wz), and
[warp.wz](https://github.com/sravioli/warp.wz) through remote plugin URLs.
Dependency failure raises. Install selected fonts yourself.
Save state outside the config directory in a writable file whose parent exists.

### Install and run

Put this in `wezterm.lua`:

```lua
local wezterm = require "wezterm"
local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"
local config = wezterm.config_builder()

lantern.rekindle(config)
config.keys = {
  { key = "p", mods = "CTRL|SHIFT", action = lantern.light.colorscheme() },
}

return config
```

Press **Ctrl+Shift+P**, type to filter, and press Enter to apply a theme.
Esc cancels. The colorscheme list includes palette swatches.
In an existing config, restore after setting your base options, but before
the final return; append the binding to your existing keys.

## Usage

### Add appearance controls

Add bindings using `lantern.light.font_size()`, `window_opacity()`, or
the other [built-in actions](#built-in-picker-actions). Each returns a native
WezTerm key assignment; creating it does not open the selector or scan flames.
Selection changes the current window's overrides. The next `rekindle` applies
saved choices to the base config, so new windows can use them too.

For font reset, set base font options first, then capture them before restore:

```lua
lantern.setup {
  default_font = {
    font = config.font,
    font_size = config.font_size,
    font_rules = config.font_rules,
    line_height = config.line_height,
  },
}
lantern.rekindle(config)
```

Font reset restores only the default-font fields you supplied. It normally
clears the saved choice, but leaves other window overrides alone.

### Build a custom selector

Register the wick after setup and before `rekindle`, so restore can find it:

```lua
lantern.add_wick("scrollback", {
  title = "Scrollback size",
  flames = {
    {
      glow = function()
        return {
          { id = "3500", label = "Compact" },
          { id = "10000", label = "Long" },
        }
      end,
      ignite = function(cfg, ctx)
        cfg.scrollback_lines = tonumber(ctx.choice.id)
      end,
    },
  },
})
```

Bind `lantern.light "scrollback"`. A flame can also be the name of a Lua
module. `glow` returns a scalar, `{ id, label? }`, or a list of choices; use unique
string IDs. `ignite` mutates the supplied config/override table.
Legacy names `get` and `pick` are aliases for `glow` and `ignite`.

During restore, callbacks may receive only `ctx.choice`, without a window or
pane. A flame restored during config evaluation must not depend on GUI state.

### Discover preset modules when needed

```lua
lantern.add_wick("profiles", {
  flame_dirs = { wezterm.config_dir .. "/lantern/profiles" },
  restore_after = "colorschemes",
})
```

Place `.lua` flame modules that can be loaded by name in that directory.
Lantern scans it when the wick first initializes, not when the plugin loads.
A string is a directory path; a string-array spec such as `{ "fonts" }` points
beneath Lantern's bundled flames. Successful lists stay cached for the process;
empty scans are retried. List modules explicitly if you need to control when
the available choices change.

## Configuration

### Example

Setup is optional. Call it before registering custom wicks and restoring:

```lua
lantern.setup {
  persistence = { path = wezterm.home_dir .. "/.lantern-state.json" },
  color = { opacity = 0.9 },
  defaults = { fuzzy = false },
}
```

The values above override the defaults. Lantern creates built-in wicks at
import time, so they keep their original selector settings. `defaults` applies
to wicks you register afterward.

### Options

#### Plugin settings

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `log.enabled` | `boolean` | `true` | Gate core diagnostics; dependency loggers can still emit their own errors. |
| `persistence.enabled` | `boolean` | `true` | Gate explicit save/clear/flush helpers; reads and legacy migration still run. |
| `persistence.path` | `string?` | `nil` | Compute `lantern-state.json` in the platform state directory when omitted. |
| `persistence.legacy_path` | `string?` | `nil` | Compute `picker-state.json` beside the default state location for migration. |
| `persistence.reset_behavior` | `"clear"\|"persist"` | `"clear"` | Clear saved reset choices, or retain them like other choices. |
| `default_font.font_size` | `number` | `10` | Font reset size in points. |
| `default_font.font` | `table?` | `nil` | Font reset family/style object. |
| `default_font.font_rules` | `table[]?` | `nil` | Font rules copied on reset. |
| `default_font.line_height` | `number?` | `nil` | Line-height multiplier copied on reset. |
| `color.opacity` | `number` | `1` | Background-layer opacity when applying a scheme; use WezTerm's `0..1` range. |
| `color.set_tab_button` | `fun(config: table, scheme: table, ctx: Lantern.ColorContext)` | `nil` | Custom new-tab button formatter; context contains optional `name`. Failure logs and uses the built-in formatter. |
| `defaults.title` | `string` | `"Light a wick"` | Title inherited by newly registered wicks. |
| `defaults.sort_by` | `string` | `"id"` | Choice field for the default comparator. |
| `defaults.fuzzy` | `boolean` | `true` | Initial fuzzy selector mode. |
| `defaults.description` | `string` | `"Select a flame."` | Exact-mode description. |
| `defaults.fuzzy_description` | `string` | `"Search"` | Fuzzy-mode prompt. |
| `defaults.alphabet` | `string` | `"1234567890abcdefghilmnopqrstuvwxyz"` | Exact-mode shortcut characters. |
| `defaults.icons.lantern` | `string` | Computed Nerd Font glyph or `""` | First available `md_lan`, `md_flashlight`, or `md_pickaxe`. |
| `defaults.icons.fuzzy.ico` | `string` | Computed `cod_search_fuzzy` glyph or `""` | Fuzzy prompt icon. |
| `defaults.icons.fuzzy.punct` | `string` | `"❭"` | Fuzzy prompt punctuation. |
| `defaults.icons.exact.ico` | `string` | Computed `cod_search` glyph or `""` | Exact prompt icon. |
| `defaults.icons.exact.punct` | `string` | `":"` | Exact prompt punctuation. |
| `defaults.comp` | `fun(field: string): function` | Built-in reset-first comparator factory | Sort reset-looking choices first, then compare field values as strings. |
| `defaults.format_choices` | `Lantern.FormatChoices` | Built-in ID/label projection | Convert internal choice records into selector choices; see [types](../plugin/lantern/config.lua). |
| `defaults.format_description` | `Lantern.FormatDescription` | Built-in icon/prompt formatter | Construct exact/fuzzy prompt text. |

#### Wick settings

Pass these in `lantern.add_wick(name, spec)`. A wick keeps the selector defaults
in effect when you register it.

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string?` | Registration name | Optional internal name; normally omit it. |
| `flames` | `(string\|Lantern.Flame)[]` | `{}` | Inline flames or require-able modules. |
| `flame_dirs` | `Lantern.FlameDir[]` | `{}` | Lazily scanned directories; see [discovery](#discover-preset-modules-when-needed). |
| `title` | `string` | `defaults.title` | Selector title. |
| `sort_by` | `string` | `defaults.sort_by` | Default comparator field. |
| `fuzzy` | `boolean` | `defaults.fuzzy` | Initial search mode. |
| `alphabet` | `string` | `defaults.alphabet` | Exact selector shortcuts. |
| `description` | `string` | `defaults.description` | Exact-mode prompt. |
| `fuzzy_description` | `string` | `defaults.fuzzy_description` | Fuzzy-mode prompt. |
| `persist` | `boolean` | `persistence.enabled` at registration | Whether selection attempts to save this wick. Global disabled writes still take precedence. |
| `restore_after` | `string\|string[]` | `{}` | Registered wick names to restore first. |
| `restore_priority` | `number` | `0` | Lower values sort first among unrelated wicks; dependencies win. |
| `comp` | `fun(a: Lantern.Choice, b: Lantern.Choice): boolean` | Computed from `defaults.comp(sort_by)` | Comparator for formatted choices. |
| `format_choices` | `Lantern.FormatChoices` | `defaults.format_choices` | Choice projection callback. |
| `format_description` | `Lantern.FormatDescription` | `defaults.format_description` | Prompt-format callback. |

### Behavior and precedence

Each setup call merges fresh defaults with your options using Warp's deep
`"force"` merge. Maps merge and lists replace. Lantern does not schema-validate
unknown settings. Existing wicks keep their selector settings; color and state
helpers read the current settings when they run.

State defaults to `%LOCALAPPDATA%\wezterm` (then `%APPDATA%\wezterm`) on Windows,
or `$XDG_STATE_HOME/wezterm` (then `$HOME/.local/state/wezterm`) elsewhere.
If those are unavailable, it falls back to `wezterm.config_dir`, then `.`.
Inspect `lantern.state.path()` and create its parent directory yourself.
Memo's file writes do not create it. Prefer an explicit writable path outside
the config directory to avoid reload loops.

`rekindle` rereads disk and applies saved flames to the supplied config.
Window overrides still take precedence over base config values.
Lantern restores dependencies first, then orders unrelated entries by
priority and name. A cycle produces a warning without stopping the whole restore.
Turning persistence off does not prevent restore or legacy migration. Omit
`rekindle` if you do not want either.

Lantern recognizes a reset by ID `"reset"` or label `"Reset"`, ignoring case.
Legacy picker state can migrate when active state is empty; module names
starting `picker.assets.` become `lantern.flames.`. GPU records keep the adapter
descriptor so restore does not need to enumerate again; old vendor-only records
enumerate once to upgrade. Reopen the GPU picker after changing hardware.

## API reference

`?` marks optional arguments or nullable results. Module calls use `.`;
wick instance calls use `:`. An action result is a WezTerm key assignment.

### Selectors and helpers

| Signature → Return type | Description |
| --- | --- |
| `lantern.setup(options?) → Lantern.Config` | Reset settings to defaults plus overrides. |
| `lantern.config.setup(options?) → Lantern.Config` | Same setup operation. |
| `lantern.config.get() → Lantern.Config` | Return the live settings reference. |
| `lantern.config.defaults() → Lantern.Config` | Deep-copy defaults. |
| `lantern.add_wick(name, spec) → Lantern.Wick` | Register/replace a wick by name. |
| `lantern.wick(name) → Lantern.Wick?` | Get the registered instance. |
| `lantern.light(name) → KeyAssignment` | Create an action for a named wick; unknown names log and return `Nop`. |
| `lantern.rekindle(config?) → table` | Restore into and return the supplied config, or a new table. |
| `wick:register(flame) → nil` | Add choices from a module name or inline flame; duplicate IDs replace earlier choices. |
| `wick:select(config, context) → nil` | Apply `context.choice` and update saved state; restore context may omit window/pane. |
| `wick:light() → KeyAssignment` | Register its selection event once and return an event action. |
| `lantern.flames.from_dir(directory) → string[]` | Discover cached module names immediately; directory is a path or bundled path segments. |
| `lantern.flames.from_dirs(directories) → string[]` | Concatenate immediate discovery results. |
| `lantern.color.scheme(name) → table?` | Get a bundled scheme by flame-module name, such as `"kanagawa-wave"`; shared table. |
| `lantern.color.apply_scheme(config, scheme, name) → nil` | Set scheme, palette/character-selector colors, background layer, and tab button. Replaces `background`. |
| `lantern.color.set_tab_button(config, scheme, name?) → nil` | Apply the configured formatter or built-in new-tab styles. |
| `lantern.gpu() → Lantern.Flame` | Get the lazy GPU flame; no enumeration yet. |
| `lantern.gpu().best() → GpuInfo?` | Enumerate/cache adapters; prefer discrete, integrated, other, then CPU. |
| `lantern.gpu().glow() → Lantern.Choice[]` | Enumerate/cache choices for the GPU picker. |
| `lantern.gpu().ignite(config, context) → nil` | Apply the saved adapter or resolve a legacy vendor ID. |

Immediate discovery can yield, so use `flame_dirs` when registering wicks
during config loading. Lantern logs flame-load failures during initialization
and skips those flames, but `ignite` errors can propagate. Make sure custom
callbacks are safe in the context where they run.

### Built-in picker actions

| Signature → Return type | Description |
| --- | --- |
| `lantern.light.colorscheme() → KeyAssignment` | `colorschemes`: bundled themes with palette swatches. |
| `lantern.light.font() → KeyAssignment` | `fonts`: bundled font presets and configured reset; install the fonts yourself. |
| `lantern.light.font_size() → KeyAssignment` | `font-sizes`: point sizes and reset. |
| `lantern.light.font_leading() → KeyAssignment` | `font-leadings`: line-height multipliers and reset. |
| `lantern.light.gpu() → KeyAssignment` | `gpus`: lazily discovered adapters. |
| `lantern.light.window_opacity() → KeyAssignment` | `window-opacity`: background opacity and reset. |
| `lantern.light.window_padding() → KeyAssignment` | `window-padding`: padding presets. |
| `lantern.light.cursor_style() → KeyAssignment` | `cursor-style`: steady/blinking cursor shapes. |
| `lantern.light.inactive_pane_opacity() → KeyAssignment` | `inactive-pane-opacity`: inactive pane HSB presets. |
| `lantern.light.font_ligatures() → KeyAssignment` | `font-ligatures`: HarfBuzz feature presets. |
| `lantern.light.tab_bar_style() → KeyAssignment` | `tab-bar-style`: native, retro, and powerline styles; restores after colorschemes. |

### Saved state

| Signature → Return type | Description |
| --- | --- |
| `lantern.state.save(wick_name, entry) → nil` | Save `{ id, label?, module?, wick?, adapter? }` when persistence is enabled. |
| `lantern.state.get(wick_name) → table?` | Read one stored entry. |
| `lantern.state.clear(wick_name?) → nil` | Clear one or all saved entries; disabled persistence prevents this. |
| `lantern.state.flush() → nil` | Save the current mirror when enabled; no success result. |
| `lantern.state.all(options?) → table` | Get normalized entries; `options.reload = true` rereads disk. |
| `lantern.state.reload() → table` | Alias for `all { reload = true }`. |
| `lantern.state.path() → string` | Resolve the active state path. |
| `lantern.state.legacy_path() → string` | Resolve the migration source path. |

`state.get` can return a GLOBAL-backed proxy; treat it as read-only.
The normalized outer tables from `all` may still contain a nested adapter proxy.

## Troubleshooting

### A selection is not restored

Register custom wicks before `rekindle`, verify the state parent directory
exists, and check the debug overlay (**Ctrl+Shift+L**). Removed flame modules
or changed choice IDs can make old records stale. Clear the affected wick's
state instead of deleting unrelated saved choices.

### The font or GPU does not change

Install the selected font. GPU choice depends on GUI enumeration and the
active graphics backend; creating a picker action alone does not enumerate.
`best()` does enumerate, so avoid it during config loading if unnecessary.

Update plugins with `wezterm.plugin.update_all()` from the debug overlay and
reload. Report [issues](https://github.com/sravioli/lantern.wz/issues) with
the wick/flame, sanitized state, plugin revision, and WezTerm build.

## Development

### Local checkout

Clone into `plugins/lantern.wz` beneath `wezterm.config_dir`, then replace
the remote import:

```lua
local wezterm = require "wezterm"
local lantern = wezterm.plugin.require(
  "file:///" .. wezterm.config_dir .. "/plugins/lantern.wz"
)
```

Its four dependencies still resolve through their remote URLs; keep them
installed for offline use.

### Editor support

Follow the [wezterm-types setup](https://github.com/DrKJeff16/wezterm-types):

```lua
---@type Lantern
local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"
```

The [published definitions](https://github.com/DrKJeff16/wezterm-types/blob/main/lua/wezterm/types/plugins/lantern.lua)
cover the main API, but omit restore ordering, saved GPU descriptors,
`color.set_tab_button`, and state reload helpers. Consult the
[core](../plugin/lantern/core.lua), [config](../plugin/lantern/config.lua), and
[state](../plugin/lantern/state.lua) annotations for this revision.

### Checks and contributions

From the repository root, with Lua 5.4 and the named tools installed:

```sh
busted --verbose
luacheck .
selene --display-style=quiet .
stylua --check .
```

The suite uses mocked dependencies and GUI APIs. Follow the
[contribution guide](contributing.md), preserve compatible defaults, and use
Conventional Commits.

## License

Code: [GNU GPL v2](../LICENSE). Documentation:
[CC BY-NC 4.0](../LICENSE-DOCS). Preserve source attribution, including the
font reset contribution credited to `sravioli, akthe-at`.
