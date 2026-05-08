---@module "lantern.api"

local config = require "lantern.config"
local core = require "lantern.core"

---@class Lantern
---@field light Lantern.LightApi
---@field flames Lantern.FlamesApi
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
  core.add_wick("window-opacity", require "lantern.wicks.window_opacity")
  core.add_wick("window-padding", require "lantern.wicks.window_padding")
  core.add_wick("cursor-style", require "lantern.wicks.cursor_style")
  core.add_wick("inactive-pane-opacity", require "lantern.wicks.inactive_pane_opacity")
  core.add_wick("font-ligatures", require "lantern.wicks.font_ligatures")
  core.add_wick("tab-bar-style", require "lantern.wicks.tab_bar_style")
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

---@return table
function light.window_opacity()
  return core.light "window-opacity"
end

---@return table
function light.window_padding()
  return core.light "window-padding"
end

---@return table
function light.cursor_style()
  return core.light "cursor-style"
end

---@return table
function light.inactive_pane_opacity()
  return core.light "inactive-pane-opacity"
end

---@return table
function light.font_ligatures()
  return core.light "font-ligatures"
end

---@return table
function light.tab_bar_style()
  return core.light "tab-bar-style"
end

M.light = setmetatable(light, light)

---@class Lantern.FlamesApi
local flames = {}

---Return cached flame module paths from one directory.
---@param dir Lantern.FlameDir
---@return string[]
function flames.from_dir(dir)
  return core.flames_from_dir(dir)
end

---Return cached flame module paths from multiple directories.
---@param dirs Lantern.FlameDir[]
---@return string[]
function flames.from_dirs(dirs)
  return core.flames_from_dirs(dirs)
end

M.flames = flames
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
