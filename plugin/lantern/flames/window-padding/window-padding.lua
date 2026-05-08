---@module "lantern.flames.window-padding.window-padding"

---@class Lantern.Flame
local M = {}

local choices = {
  {
    id = "compact",
    label = "Compact",
    value = { left = 2, right = 2, top = 0, bottom = 0 },
  },
  {
    id = "normal",
    label = "Normal",
    value = { left = "0.5cell", right = "0.5cell", top = "0.25cell", bottom = "0.25cell" },
  },
  {
    id = "spacious",
    label = "Spacious",
    value = { left = "1cell", right = "1cell", top = "0.5cell", bottom = "0.5cell" },
  },
  {
    id = "wide",
    label = "Wide",
    value = { left = "2cell", right = "2cell", top = "1cell", bottom = "1cell" },
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
    cfg.window_padding = nil
    return
  end

  cfg.window_padding = copy(values[ctx.choice.id])
end

return M
