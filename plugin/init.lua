---@class Wezterm
local wz = require "wezterm" --[[@as Wezterm]]

---Locate the plugin's `plugin_dir` and add it to `package.path`.
---@param name string Substring to match against plugin URLs.
---@return table|nil plugin Installed plugin entry.
local function bootstrap(name)
  -- selene: allow(incorrect_standard_library_use)
  local sep = package.config:sub(1, 1)

  local plugins = wz.plugin.list()
  for i = 1, #plugins do
    local p = plugins[i]
    if p.url:find(name, 1, true) then
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
end

bootstrap "lantern.wz"

return require "lantern.api"
