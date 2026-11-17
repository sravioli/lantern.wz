---@module "lantern"
---@author sravioli
---@license GNU-GPLv2

---@class Wezterm
local wezterm = require "wezterm" --[[@as Wezterm]]
local module_name = ...

---Locate this plugin_dir and add it to package.path.
---@return table|nil plugin Installed plugin entry.
local function bootstrap(refresh)
  -- selene: allow(incorrect_standard_library_use)
  local sep = package.config:sub(1, 1)

  -- The snapshot also lives in GLOBAL so config reloads skip plugin.list()
  -- (about 20 ms); a plugin missing from it triggers a refresh below.
  local global = wezterm.GLOBAL
  local plugins = not refresh
    and (wezterm.plugin._bootstrap_plugins or (global and global.__bootstrap_plugins))
  if not plugins then
    plugins = wezterm.plugin.list()
    wezterm.plugin._bootstrap_plugins = plugins
    if global and #plugins > 0 then
      global.__bootstrap_plugins = plugins
    end
  end
  for _, p in ipairs(plugins) do
    if
      (module_name and p.component == module_name)
      or (not module_name and p.url:find("lantern.wz", 1, true))
    then
      local base = p.plugin_dir .. sep .. "plugin" .. sep
      local entries = {
        base .. "?.lua",
        base .. "?" .. sep .. "init.lua",
      }
      for _, entry in ipairs(entries) do
        if not package.path:find(entry, 1, true) then
          package.path = package.path .. ";" .. entry
        end
      end
      -- lantern.meta reads the plugin's own files from here.
      wezterm.GLOBAL = wezterm.GLOBAL or {}
      wezterm.GLOBAL.__lantern_plugin_dir = p.plugin_dir
      return p
    end
  end
  if not refresh then
    return bootstrap(true)
  end
  error "Installed plugin not found: lantern.wz"
end

bootstrap()

return require "lantern.api"
