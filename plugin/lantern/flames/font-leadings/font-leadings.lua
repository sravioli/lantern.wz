---@module "lantern.flames.font-leadings.font-leadings"
---@author akthe-at, sravioli

---@class Lantern.Flame
local M = {}

M.glow = function()
  local leadings_list = { { label = "Reset Line Height to Default", id = "reset" } }
  -- Integer steps: adding 0.1 repeatedly drifts past 1.4 and drops it.
  for i = 9, 14 do
    local v = i / 10
    table.insert(leadings_list, { label = ("%.1fx"):format(v), id = ("%.1f"):format(v) })
  end
  return leadings_list
end

M.ignite = function(config, opts)
  if opts.choice.id == "reset" then
    config.line_height = nil
  else
    config.line_height = tonumber(opts.choice.id)
  end
end

return M
