# lantern.wz

Lantern is a WezTerm plugin for lighting configurable selection wicks.

It ships with built-in wicks for colorschemes, fonts, font sizes, line height,
and GPU adapters, while also letting users add their own wicks and flames.

## Installation

```lua
local wezterm = require "wezterm"

local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"
```

Lantern loads `log.wz`, `memo.wz`, and `warp.wz` through
`wezterm.plugin.require` for logging, persistent state, cached discovery, and
shared path/table/string helpers.

## Basic Usage

```lua
local wezterm = require "wezterm"
local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"

local config = wezterm.config_builder()

lantern.setup {
  default_font = {
    font_size = config.font_size,
    font = config.font,
    font_rules = config.font_rules,
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
}

return config
```

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
| `lantern.light(name)` | Return a WezTerm action for a custom wick. |
| `lantern.add_wick(name, spec)` | Register a custom wick. |
| `lantern.wick(name)` | Return a registered wick. |
| `lantern.flames.from_dir(path_or_segments)` | Return a cached static flame list from one directory. |
| `lantern.flames.from_dirs(paths)` | Return a cached static flame list from multiple directories. |
| `lantern.gpu().best()` | Return the best detected GPU adapter. |

## Custom Wicks

A wick is a named collection of flames. A flame provides `glow()` entries and an
`ignite(config, ctx)` function that applies the selected entry.

```lua
local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"

lantern.add_wick("window-opacity", {
  title = "Lantern: window opacity",
  flames = {
    {
      glow = function()
        return {
          { id = "0.85", label = "Dim" },
          { id = "1.00", label = "Solid" },
        }
      end,

      ignite = function(config, ctx)
        config.window_background_opacity = tonumber(ctx.choice.id)
      end,
    },
  },
})

-- Bind with:
-- lantern.light "window-opacity"
```

Flames can also be Lua modules:

```lua
lantern.add_wick("profiles", {
  title = "Lantern: profile",
  flames = {
    "my_lantern_flames.work",
    "my_lantern_flames.home",
  },
})
```

For folder-backed flames, build a cached static list from a directory:

```lua
lantern.add_wick("profiles", {
  title = "Lantern: profile",
  flames = lantern.flames.from_dir(wezterm.config_dir .. "/lantern/profiles"),
})
```

`from_dir()` scans once per config/plugin load and returns module paths. Repeated
calls for the same directory reuse the cached list, so opening a wick does not
rescan that folder. Built-in Lantern wicks use this path for their shipped
flames.

Each module should return:

```lua
local M = {}

function M.glow()
  return { id = "work", label = "Work" }
end

function M.ignite(config, ctx)
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

return M
```

## Persistence

Selections are stored outside `wezterm.config_dir` by default so writes do not
trigger config reloads:

- Windows: `%LOCALAPPDATA%\wezterm\lantern-state.json`
- Linux/macOS: `$XDG_STATE_HOME/wezterm/lantern-state.json`

Override the path with:

```lua
lantern.setup {
  persistence = {
    path = "C:/path/to/lantern-state.json",
    reset_behavior = "clear",
  },
}
```

`reset_behavior = "clear"` removes a wick's persisted value when a flame with
`id = "reset"` is selected. Use `"persist"` to store reset selections.
