---@module "lantern.deps"

local wezterm = require "wezterm"

local M = {}

local function require_plugin(url)
  local ok, plugin = pcall(wezterm.plugin.require, url)
  if ok and plugin then
    return plugin
  end

  error(("[lantern] unable to load dependency %s: %s"):format(url, tostring(plugin)))
end

M.log = require_plugin "https://github.com/sravioli/log.wz"
M.memo = require_plugin "https://github.com/sravioli/memo.wz"
M.ribbon = require_plugin "https://github.com/sravioli/ribbon.wz"
M.warp = require_plugin "https://github.com/sravioli/warp.wz"

return M
