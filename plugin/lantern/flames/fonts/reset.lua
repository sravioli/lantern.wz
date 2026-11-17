---@module "lantern.flames.fonts.reset"
---@author sravioli, akthe-at

---@class Lantern.Flame
local M = {}

local config = require "lantern.config"

M.glow = function()
  return { id = "reset", label = "Restore fonts to default" }
end

M.ignite = function(Config, _)
  -- Every font flame sets these too; clear them so the config file's font returns.
  Config.font = nil
  Config.font_rules = nil
  for key, value in pairs(config.get().default_font or {}) do
    Config[key] = value
  end
end

return M
