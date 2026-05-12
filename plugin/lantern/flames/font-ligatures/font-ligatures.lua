---@module "lantern.flames.font-ligatures.font-ligatures"

---@class Lantern.Flame
local M = {}

local tbl = require("lantern.deps").warp.table

local choices = {
  { id = "standard", label = "Standard", value = { "calt", "clig", "liga" } },
  { id = "discretionary", label = "Discretionary", value = { "calt", "clig", "liga", "dlig" } },
  { id = "off", label = "Off", value = { "calt=0", "clig=0", "liga=0" } },
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
    cfg.harfbuzz_features = nil
    return
  end

  cfg.harfbuzz_features = tbl.copy(values[ctx.choice.id])
end

return M
