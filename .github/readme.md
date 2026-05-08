# lantern.wz

[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/lantern.wz/tests.yaml?label=Tests&logo=Lua)](https://github.com/sravioli/lantern.wz/actions?workflow=tests)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/lantern.wz/lint.yaml?label=Lint&logo=Lua)](https://github.com/sravioli/lantern.wz/actions?workflow=lint)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/lantern.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/lantern.wz)

Configurable selection workflows for
[WezTerm](https://wezfurlong.org/wezterm/) plugins and configuration code.

Lantern exposes selection actions as named **wicks**. Each wick is backed by
one or more **flames** that provide choices with `glow()` and apply selections
with `ignite(config, ctx)`.

- Built-in wicks for colorschemes, fonts, font sizing, GPU selection, window
  appearance, cursor style, ligatures, and tab bar style
- User-defined wicks backed by inline flames, module flames, or flame folders
- Persistent selections restored during startup with `lantern.rekindle(config)`
- Safe reset handling for choices named `reset`
- Cached flame directory discovery through `memo.wz`
- Color preview formatting for colorscheme choices
- Shared logging and helpers through `log.wz`, `memo.wz`, and `warp.wz`

## Installation

```lua
local wezterm = require "wezterm"

-- from git
local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"

-- from a local checkout
local lantern = wezterm.plugin.require("file:///" .. wezterm.config_dir .. "/plugins/lantern.wz")
```

Lantern loads these WezTerm plugin dependencies automatically:

- [`log.wz`](https://github.com/sravioli/log.wz) for tagged logging
- [`memo.wz`](https://github.com/sravioli/memo.wz) for cache and state storage
- [`warp.wz`](https://github.com/sravioli/warp.wz) for path, table, and string helpers

### Type annotations

Lantern modules use LuaCATS annotations. After installing WezTerm Lua types,
annotate the import to get autocompletion and type checking:

```lua
---@type Lantern
local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"
```

## Quick Start

```lua
local wezterm = require "wezterm"
local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"

local config = wezterm.config_builder()

lantern.setup {
  default_font = {
    font_size = config.font_size,
    font = config.font,
    font_rules = config.font_rules,
    line_height = config.line_height,
  },
  color = {
    opacity = 1,
  },
}

lantern.rekindle(config)

config.keys = {
  { key = "c", mods = "CTRL|SHIFT", action = lantern.light.colorscheme() },
  { key = "f", mods = "CTRL|SHIFT", action = lantern.light.font() },
  { key = "s", mods = "CTRL|SHIFT", action = lantern.light.font_size() },
  { key = "l", mods = "CTRL|SHIFT", action = lantern.light.font_leading() },
  { key = "g", mods = "CTRL|SHIFT", action = lantern.light.gpu() },
}

return config
```

## Built-In Wicks

| Wick | Action | Description |
| --- | --- | --- |
| `colorschemes` | `lantern.light.colorscheme()` | Pick a bundled colorscheme and apply preview-aware overrides. |
| `fonts` | `lantern.light.font()` | Pick a bundled font preset or reset to `default_font`. |
| `font-sizes` | `lantern.light.font_size()` | Pick a font size from 8pt through 30pt, plus reset. |
| `font-leadings` | `lantern.light.font_leading()` | Pick a line-height value or reset to default. |
| `gpus` | `lantern.light.gpu()` | Pick a GPU adapter from `wezterm.gui.enumerate_gpus()`. |
| `window-opacity` | `lantern.light.window_opacity()` | Pick a window background opacity or reset to the base config. |
| `window-padding` | `lantern.light.window_padding()` | Pick compact, normal, spacious, or wide window padding. |
| `cursor-style` | `lantern.light.cursor_style()` | Pick a steady or blinking cursor shape. |
| `inactive-pane-opacity` | `lantern.light.inactive_pane_opacity()` | Pick inactive pane dimming through `inactive_pane_hsb`. |
| `font-ligatures` | `lantern.light.font_ligatures()` | Pick standard, discretionary, or disabled HarfBuzz ligatures. |
| `tab-bar-style` | `lantern.light.tab_bar_style()` | Pick native, retro, or bundled powerline tab styling. |

Built-in flame modules live under `plugin/lantern/flames`.

## Public API

| API | Description |
| --- | --- |
| `lantern.setup(opts)` | Merge user options into Lantern defaults. |
| `lantern.rekindle(config?)` | Restore persisted selections into a config table. |
| `lantern.light.colorscheme()` | Return a WezTerm action for the built-in colorscheme wick. |
| `lantern.light.font()` | Return a WezTerm action for the built-in font wick. |
| `lantern.light.font_size()` | Return a WezTerm action for the built-in font-size wick. |
| `lantern.light.font_leading()` | Return a WezTerm action for the built-in line-height wick. |
| `lantern.light.gpu()` | Return a WezTerm action for the built-in GPU wick. |
| `lantern.light.window_opacity()` | Return a WezTerm action for the built-in window-opacity wick. |
| `lantern.light.window_padding()` | Return a WezTerm action for the built-in window-padding wick. |
| `lantern.light.cursor_style()` | Return a WezTerm action for the built-in cursor-style wick. |
| `lantern.light.inactive_pane_opacity()` | Return a WezTerm action for the built-in inactive-pane-opacity wick. |
| `lantern.light.font_ligatures()` | Return a WezTerm action for the built-in font-ligatures wick. |
| `lantern.light.tab_bar_style()` | Return a WezTerm action for the built-in tab-bar-style wick. |
| `lantern.light(name)` | Return a WezTerm action for a custom wick. |
| `lantern.add_wick(name, spec)` | Register a custom wick. |
| `lantern.wick(name)` | Return a registered wick. |
| `lantern.flames.from_dir(path_or_segments)` | Return cached flame module paths from one directory. |
| `lantern.flames.from_dirs(paths)` | Return cached flame module paths from multiple directories. |
| `lantern.color.scheme(name)` | Return a built-in colorscheme table by name. |
| `lantern.gpu().best()` | Return the best detected GPU adapter. |

## Configuration

```lua
lantern.setup {
  log = {
    enabled = true,
  },
  persistence = {
    enabled = true,
    path = nil,
    legacy_path = nil,
    reset_behavior = "clear",
  },
  default_font = {
    font_size = 10,
  },
  color = {
    opacity = 1,
  },
  defaults = {
    title = "Light a wick",
    sort_by = "id",
    fuzzy = true,
    description = "Select a flame.",
    fuzzy_description = "Search",
    alphabet = "1234567890abcdefghilmnopqrstuvwxyz",
  },
}
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `log.enabled` | boolean | `true` | Enables Lantern logging. |
| `persistence.enabled` | boolean | `true` | Saves selected choices for startup restore. |
| `persistence.path` | string? | auto | State file path. |
| `persistence.legacy_path` | string? | auto | Legacy picker state path used for migration. |
| `persistence.reset_behavior` | `"clear"` or `"persist"` | `"clear"` | How reset selections affect stored state. |
| `default_font` | table | `{ font_size = 10 }` | Values restored by the font reset flame. |
| `color.opacity` | number | `1` | Opacity used by built-in colorscheme backgrounds. |
| `defaults.title` | string | `"Light a wick"` | Default selector title. |
| `defaults.sort_by` | string | `"id"` | Choice field used for default sorting. |
| `defaults.fuzzy` | boolean | `true` | Enables fuzzy input selector mode. |
| `defaults.description` | string | `"Select a flame."` | Prompt text in exact mode. |
| `defaults.fuzzy_description` | string | `"Search"` | Prompt text in fuzzy mode. |
| `defaults.alphabet` | string | digits and letters | Input selector shortcut alphabet. |

## Custom Wicks

A wick is a named collection of flames. A flame can expose either:

- `glow(ctx?)`, returning one choice or a list of choices
- `ignite(config, ctx)`, applying the selected choice

Legacy names `get()` and `pick(config, ctx)` are also accepted.

### Inline flames

```lua
lantern.add_wick("scrollback-size", {
  title = "Lantern: scrollback size",
  flames = {
    {
      glow = function()
        return {
          { id = "3500", label = "Default" },
          { id = "10000", label = "Long" },
          { id = "50000", label = "Archive" },
        }
      end,

      ignite = function(config, ctx)
        config.scrollback_lines = tonumber(ctx.choice.id)
      end,
    },
  },
})

-- Bind with:
-- lantern.light "scrollback-size"
```

### Module flames

```lua
lantern.add_wick("profiles", {
  title = "Lantern: profile",
  flames = {
    "my_lantern_flames.work",
    "my_lantern_flames.home",
  },
})
```

Each module should return a flame:

```lua
local M = {}

function M.glow()
  return { id = "work", label = "Work" }
end

function M.ignite(config, ctx)
  config.default_prog = { "pwsh.exe", "-NoLogo" }
  config.launch_menu = {
    { label = ctx.choice.label, args = config.default_prog },
  }
end

return M
```

### Folder-backed flames

Use `flame_dirs` when a wick should load every `.lua` flame module from a
folder. This is the recommended path for user-defined stores/assets because
the folder is scanned on the first time the wick is opened, not while the
plugin is being required.

```lua
lantern.add_wick("profiles", {
  title = "Lantern: profile",
  flame_dirs = {
    wezterm.config_dir .. "/lantern/profiles",
  },
})
```

`flame_dirs` accepts absolute directory paths. Built-in wicks pass path
segments such as `{ "colorschemes" }`, which Lantern resolves under
`plugin/lantern/flames`.

For advanced cases, `lantern.flames.from_dir(path)` returns a cached list of
module paths immediately:

```lua
lantern.add_wick("profiles", {
  title = "Lantern: profile",
  flames = lantern.flames.from_dir(wezterm.config_dir .. "/lantern/profiles"),
})
```

Use immediate expansion only when you specifically want a static module list at
configuration time. `flame_dirs` is safer for normal WezTerm picker flows.

## Choice Model

`glow()` may return a string, number, choice table, or list of choice tables.
Lantern normalizes each entry into this shape:

```lua
{
  id = "required-id",
  label = "Optional display label",
}
```

Selection callbacks receive this context:

```lua
{
  window = window,
  pane = pane,
  choice = { id = "required-id", label = "Optional display label" },
  wick = wick,
}
```

## Persistence

Selections are stored outside `wezterm.config_dir` by default so writes do not
trigger config reloads:

| OS | Default path |
| --- | --- |
| Windows | `%LOCALAPPDATA%\wezterm\lantern-state.json` |
| Linux / macOS | `$XDG_STATE_HOME/wezterm/lantern-state.json` |

Override the path with:

```lua
lantern.setup {
  persistence = {
    path = "C:/path/to/lantern-state.json",
    reset_behavior = "clear",
  },
}
```

`lantern.rekindle(config)` reads stored choices and applies their flames to the
given config table.

`reset_behavior = "clear"` removes a wick's persisted value when a flame with
`id = "reset"` or label `"Reset"` is selected. Use `"persist"` to store reset
selections.

Lantern also performs a one-time migration from legacy picker state by
rewriting module paths from `picker.assets.*` to `lantern.flames.*`.

## GPU Helper

The GPU flame can be used without opening the selector:

```lua
local gpu = lantern.gpu().best()

if gpu then
  config.webgpu_preferred_adapter = gpu
end
```

The helper prefers discrete GPUs, then integrated GPUs, then other adapters,
using the preferred backend for the current platform when possible.

## Examples

Add custom command profiles:

```lua
lantern.add_wick("profiles", {
  title = "Lantern: profile",
  flames = {
    {
      glow = function()
        return {
          { id = "pwsh", label = "PowerShell" },
          { id = "wsl", label = "WSL" },
        }
      end,
      ignite = function(config, ctx)
        if ctx.choice.id == "pwsh" then
          config.default_prog = { "pwsh.exe", "-NoLogo" }
        elseif ctx.choice.id == "wsl" then
          config.default_prog = { "wsl.exe" }
        end
      end,
    },
  },
})
```

Add command palette entries:

```lua
wezterm.on("augment-command-palette", function()
  return {
    {
      brief = "Lantern: colorscheme",
      icon = "md_palette",
      action = lantern.light.colorscheme(),
    },
    {
      brief = "Lantern: font",
      icon = "md_format_font",
      action = lantern.light.font(),
    },
  }
end)
```

## License

Code is licensed under the [GNU General Public License v2](../LICENSE). Documentation
is licensed under [Creative Commons Attribution-NonCommercial 4.0 International](../LICENSE-DOCS).
