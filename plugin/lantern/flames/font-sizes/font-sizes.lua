---@module "lantern.flames.font-sizes.font-sizes"

---@class Lantern.Flame
local M = {}

local config = require "lantern.config"

M.glow = function()
  local sizes = {}
  for i = 8, 30 do
    sizes[#sizes + 1] = { label = ("%2dpt"):format(i), id = tostring(i) }
  end
  sizes[#sizes + 1] = { id = tostring(config.get().default_font.font_size or 10), label = "Reset" }

  return sizes
end

M.ignite = function(Config, opts)
  Config.font_size = tonumber(opts.choice.id) or config.get().default_font.font_size or 10
end

return M
