---@module "lantern.api"

local config = require "lantern.config"
local core = require "lantern.core"

---@class Lantern
---@field light Lantern.LightApi
---@field config table
---@field color table
---@field state table
local M = {}

local function register_builtins()
  core.add_wick("colorschemes", require "lantern.wicks.colorscheme")
  core.add_wick("fonts", require "lantern.wicks.font")
  core.add_wick("font-sizes", require "lantern.wicks.font_size")
  core.add_wick("font-leadings", require "lantern.wicks.font_leading")
  core.add_wick("gpus", require "lantern.wicks.gpu")
end

register_builtins()

---@class Lantern.LightApi
local light = {}

---@param name string
---@return table
function light.__call(_, name)
  return core.light(name)
end

---@return table
function light.colorscheme()
  return core.light "colorschemes"
end

---@return table
function light.font()
  return core.light "fonts"
end

---@return table
function light.font_size()
  return core.light "font-sizes"
end

---@return table
function light.font_leading()
  return core.light "font-leadings"
end

---@return table
function light.gpu()
  return core.light "gpus"
end

M.light = setmetatable(light, light)
M.config = config
M.color = require "lantern.color"
M.state = require "lantern.state"

---Configure Lantern.
---@param opts? table
---@return Lantern.Config
function M.setup(opts)
  return config.setup(opts)
end

---Register a user-defined wick.
---@param name string
---@param spec Lantern.WickSpec|Lantern.Wick
---@return Lantern.Wick
function M.add_wick(name, spec)
  return core.add_wick(name, spec)
end

---Return a registered wick by name.
---@param name string
---@return Lantern.Wick|nil
function M.wick(name)
  return core.get_wick(name)
end

---Restore persisted Lantern selections into a config table.
---@param cfg? table
---@return table
function M.rekindle(cfg)
  return core.rekindle(cfg)
end

---Return the built-in GPU flame module.
---@return Lantern.Flame
function M.gpu()
  return require "lantern.flames.gpus.gpus"
end

return M
