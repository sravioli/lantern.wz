---@module "lantern.flames.inactive-pane-opacity.inactive-pane-opacity"

---@class Lantern.Flame
local M = {}

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

local function copy(value)
  if type(value) ~= "table" then
    return value
  end

  local result = {}
  for key, item in pairs(value) do
    result[key] = item
  end
  return result
end

M.glow = function()
  return choices
end

M.ignite = function(cfg, ctx)
  if ctx.choice.id == "reset" then
    cfg.inactive_pane_hsb = nil
    return
  end

  cfg.inactive_pane_hsb = copy(values[ctx.choice.id])
end

return M
