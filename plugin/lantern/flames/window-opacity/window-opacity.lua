---@module "lantern.flames.window-opacity.window-opacity"

---@class Lantern.Flame
local M = {}

local choices = {
  { id = "0.75", label = "75% - transparent", value = 0.75 },
  { id = "0.85", label = "85% - dim", value = 0.85 },
  { id = "0.95", label = "95% - subtle", value = 0.95 },
  { id = "1.00", label = "100% - opaque", value = 1 },
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
    cfg.window_background_opacity = nil
    return
  end

  cfg.window_background_opacity = values[ctx.choice.id]
end

return M
