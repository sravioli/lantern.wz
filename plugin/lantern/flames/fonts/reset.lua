---@module "lantern.flames.fonts.reset"
---@author sravioli, akthe-at

---@class Lantern.Flame
local M = {}

local config = require "lantern.config"

M.glow = function()
  return { id = "reset", label = "Restore fonts to default" }
end

M.ignite = function(Config, _)
  for key, value in pairs(config.get().default_font or {}) do
    Config[key] = value
  end
end

return M
