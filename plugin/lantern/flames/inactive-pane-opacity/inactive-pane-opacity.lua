---@module "lantern.flames.inactive-pane-opacity.inactive-pane-opacity"

---@class Lantern.Flame
local M = {}

local tbl = require("lantern.deps").warp.table

local choices = {
  {
    id = "off",
    label = "Off",
    value = { saturation = 1, brightness = 1 },
  },
  {
    id = "subtle",
    label = "Subtle",
    value = { saturation = 0.95, brightness = 0.9 },
  },
  {
    id = "dim",
    label = "Dim",
    value = { saturation = 0.85, brightness = 0.75 },
  },
  {
    id = "strong",
    label = "Strong",
    value = { saturation = 0.75, brightness = 0.6 },
  },
  { id = "reset", label = "Reset" },
}

local values = {}
for i = 1, #choices do
  values[choices[i].id] = choices[i].value
end

M.glow = function()
  return choices
end

M.ignite = function(cfg, ctx)
  if ctx.choice.id == "reset" then
    cfg.inactive_pane_hsb = nil
    return
  end

  cfg.inactive_pane_hsb = tbl.copy(values[ctx.choice.id])
end

return M
