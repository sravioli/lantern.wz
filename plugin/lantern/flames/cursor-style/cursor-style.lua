---@module "lantern.flames.cursor-style.cursor-style"

---@class Lantern.Flame
local M = {}

local choices = {
  { id = "steady-block", label = "Steady block", value = "SteadyBlock" },
  { id = "blinking-block", label = "Blinking block", value = "BlinkingBlock" },
  { id = "steady-bar", label = "Steady bar", value = "SteadyBar" },
  { id = "blinking-bar", label = "Blinking bar", value = "BlinkingBar" },
  { id = "steady-underline", label = "Steady underline", value = "SteadyUnderline" },
  { id = "blinking-underline", label = "Blinking underline", value = "BlinkingUnderline" },
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
    cfg.default_cursor_style = nil
    return
  end

  cfg.default_cursor_style = values[ctx.choice.id]
end

return M
