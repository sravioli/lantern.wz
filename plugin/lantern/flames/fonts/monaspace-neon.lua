---@module "lantern.flames.fonts.monaspace-neon"
---@author sravioli, akthe-at

---@class Lantern.Flame
local M = {}

local wt = require "wezterm"

M.glow = function()
  return { id = "monaspace-neon", label = "Monaspace Neon" }
end

M.ignite = function(Config, _)
  Config.font = wt.font_with_fallback {
    {
      family = "Monaspace Neon",
      weight = "Regular",
      harfbuzz_features = {
        "cv06",
        "cv12",
        "cv14",
        "cv16",
        "cv25",
        "cv26",
        "cv28",
        "cv29",
        "cv31",
        "cv32",
        "ss03",
        "ss04",
        "ss05",
        "ss07",
        "ss09",
      },
    },
    { family = "Noto Color Emoji" },
    { family = "LegacyComputing" },
  }

  Config.font_rules = {
    {
      intensity = "Normal",
      italic = true,
      font = wt.font("Monaspace Radon", { weight = "Regular" }),
    },
    {
      intensity = "Bold",
      italic = false,
      font = wt.font("Monaspace Neon", { weight = "ExtraBold" }),
    },
    {
      intensity = "Bold",
      italic = true,
      font = wt.font("Monaspace Radon", { weight = "ExtraBold" }),
    },
  }
end

return M
