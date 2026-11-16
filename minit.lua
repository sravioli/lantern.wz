---Minimal config for bug reports. Run it in isolation from your own config:
---
---    wezterm --config-file minit.lua
---
---Put your reproduction below the marker. Keep it as small as possible and
---paste the edited file into the bug report.
local wezterm = require "wezterm"
local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"
local config = wezterm.config_builder()

-- Edit below this line --------------------------------------------------------

lantern.rekindle(config)
config.keys = {
  { key = "p", mods = "CTRL|SHIFT", action = lantern.light.colorscheme() },
}

return config
