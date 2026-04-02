---@class Wezterm
local wz = require "wezterm" --[[@as Wezterm]]

---Locate the plugin's `plugin_dir` and add it to `package.path`.
---
---Iterates the installed WezTerm plugins looking for one whose URL
---contains `name`. When found, appends the plugin's
---`plugin_dir/plugin/?.lua` entry to `package.path` so that
---sub-modules can be loaded with `require`. Does nothing if the
---path entry already exists or no matching plugin is found.
---
---@param name string Substring to match against plugin URLs.
---@return nil
local function bootstrap(name)
  -- selene: allow(incorrect_standard_library_use)
  local sep = package.config:sub(1, 1)

  local plugins = wz.plugin.list()
  for i = 1, #plugins do
    local p = plugins[i]
    if p.url:find(name, 1, true) then
      local path_entry = p.plugin_dir .. sep .. "plugin" .. sep .. "?.lua"
      if not package.path:find(path_entry, 1, true) then
        package.path = package.path .. ";" .. path_entry
      end
      return
    end
  end
end

bootstrap "lantern.wz"

return require "lantern.api"
