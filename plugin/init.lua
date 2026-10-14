---@class Wezterm
local wz = require "wezterm" --[[@as Wezterm]]
local module_name = ...

---Locate the plugin's `plugin_dir` and add it to `package.path`.
---@param name string Substring to match against plugin URLs.
---@return table|nil plugin Installed plugin entry.
local function bootstrap(name, refresh)
  -- selene: allow(incorrect_standard_library_use)
  local sep = package.config:sub(1, 1)

  local plugins = not refresh and wz.plugin._bootstrap_plugins
  if not plugins then
    plugins = wz.plugin.list()
    wz.plugin._bootstrap_plugins = plugins
  end
  for i = 1, #plugins do
    local p = plugins[i]
    if
      (module_name and p.component == module_name)
      or (not module_name and p.url:find(name, 1, true))
    then
      local base = p.plugin_dir .. sep .. "plugin" .. sep
      local entries = {
        base .. "?.lua",
        base .. "?" .. sep .. "init.lua",
      }

      for j = 1, #entries do
        local path_entry = entries[j]
        if not package.path:find(path_entry, 1, true) then
          package.path = package.path .. ";" .. path_entry
        end
      end

      wz.GLOBAL = wz.GLOBAL or {}
      wz.GLOBAL.__lantern_plugin_dir = p.plugin_dir
      return p
    end
  end
  if not refresh then
    return bootstrap(name, true)
  end
  error("Installed plugin not found: " .. name)
end

bootstrap "lantern.wz"

return require "lantern.api"
