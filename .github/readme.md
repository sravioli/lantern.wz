# lantern.wz

[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/lantern.wz/tests.yaml?label=Tests&logo=Lua)](https://github.com/sravioli/lantern.wz/actions?workflow=tests)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/lantern.wz/lint.yaml?label=Lint&logo=Lua)](https://github.com/sravioli/lantern.wz/actions?workflow=lint)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/lantern.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/lantern.wz)

Lantern is a [WezTerm](https://wezfurlong.org/wezterm/) plugin for configurable
selection workflows.

It provides selection actions as named **wicks**. Each wick is backed by one or
more **flames** that expose choices with `glow()` and apply selections with
`ignite(config, ctx)`.

## Installation

```lua
local wezterm = require "wezterm"

local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"
```

Lantern loads `log.wz`, `memo.wz`, and `warp.wz` as WezTerm plugin
dependencies.

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

## Built-In Wicks

- `colorschemes`
- `fonts`
- `font-sizes`
- `font-leadings`
- `gpus`

## Custom Wicks

```lua
lantern.add_wick("profiles", {
  title = "Lantern: profile",
  flames = lantern.flames.from_dir(wezterm.config_dir .. "/lantern/profiles"),
})
```

See the root [README](../README.md) for the full API and persistence details.
