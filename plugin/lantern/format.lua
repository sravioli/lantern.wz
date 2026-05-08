---@module "lantern.format"

local config = require "lantern.config"
local deps = require "lantern.deps"
local ribbon = deps.ribbon
local str = deps.warp.string

local M = {}

---@param text string
---@return integer
function M.width(text)
  return str.width(text)
end

---@param name? string
---@param atomic? boolean
---@return Ribbon
function M.layout(name, atomic)
  return ribbon:new(name or "Lantern", atomic)
end

---@param desc string
---@param fuzzy boolean
---@return string
function M.description(desc, fuzzy)
  local cfg = config.get()
  return cfg.defaults.format_description(desc, fuzzy, cfg.defaults.icons)
end

return M
