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

M.warp = require_plugin "https://github.com/sravioli/warp.wz"
M.log = M.warp.log
M.memo = require_plugin "https://github.com/sravioli/memo.wz"
M.ribbon = M.warp.ribbon
local warden, sigil

---Loaded on first use, so users who set `validate = false` never pull warden.
---@return Warden
function M.warden()
  warden = warden or require_plugin "https://github.com/sravioli/warden.wz"
  return warden
end

---Loaded on first use; every Lantern glyph comes from it.
---@return table
function M.sigil()
  sigil = sigil or require_plugin "https://github.com/sravioli/sigil.wz"
  return sigil
end

---A sigil symbol by dotted path, or `fallback` (default `""`) when this sigil
---has no such path, e.g. an older cached clone.
---@param path string
---@param fallback? string
---@return string
function M.symbol(path, fallback)
  local glyph = M.sigil().symbol(path)
  if type(glyph) ~= "string" then
    return fallback or ""
  end
  return glyph
end

return M
