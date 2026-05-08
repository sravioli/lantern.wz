---@module "lantern.flames.font-leadings.font-leadings"
---@author akthe-at, sravioli

---@class Lantern.Flame
local M = {}

M.glow = function()
  local leadings_list = { { label = "Reset Line Height to Default", id = "reset" } }
  for i = 0.9, 1.4, 0.1 do
    table.insert(leadings_list, { label = i .. "x", id = tostring(i) })
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
