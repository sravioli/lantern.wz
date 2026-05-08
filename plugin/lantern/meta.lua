---@module "lantern.meta"

local wezterm = require "wezterm"

local M = {}

local function sep()
  -- selene: allow(incorrect_standard_library_use)
  return package.config:sub(1, 1)
end

local function find_plugin_dir()
  if wezterm.GLOBAL and wezterm.GLOBAL.__lantern_plugin_dir then
    return wezterm.GLOBAL.__lantern_plugin_dir
  end

  if wezterm.plugin and wezterm.plugin.list then
    local plugins = wezterm.plugin.list()
    for i = 1, #plugins do
      local plugin = plugins[i]
      if plugin.url and plugin.url:find("lantern.wz", 1, true) then
        return plugin.plugin_dir
      end
    end
  end

  return nil
end

---@return string|nil
function M.plugin_dir()
  return find_plugin_dir()
end

---@param ... string
---@return string|nil
function M.plugin_path(...)
  local dir = find_plugin_dir()
  if not dir then
    return nil
  end

  local parts = { ... }
  local result = dir
  local separator = sep()
  for i = 1, #parts do
    result = result .. separator .. parts[i]
  end
  return result
end

return M
