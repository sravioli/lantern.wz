---@module "lantern.flames.tab-bar-style.tab-bar-style"

---@class Lantern.Flame
local M = {}

local wezterm = require "wezterm"
local ribbon = require("lantern.deps").ribbon
local nf = wezterm.nerdfonts or {}

local choices = {
  { id = "native", label = "Native tab bar" },
  { id = "retro", label = "Retro tab bar" },
  { id = "powerline", label = "Powerline tab bar" },
  { id = "reset", label = "Reset" },
}

local function segment(bg, fg, text)
  return ribbon:new("TabBarStyle"):append(bg, fg, text):format()
end

local function powerline_style()
  local left = nf.ple_lower_left_triangle or "<"
  local right = nf.ple_upper_right_triangle or ">"

  return {
    active_tab_left = segment("#7e9cd8", "#1f1f28", " " .. left),
    active_tab_right = segment("#7e9cd8", "#1f1f28", right .. " "),
    inactive_tab_left = segment("#2a2a37", "#7e9cd8", " " .. left),
    inactive_tab_right = segment("#2a2a37", "#7e9cd8", right .. " "),
    new_tab_left = segment("#1f1f28", "#7e9cd8", " " .. left),
    new_tab_right = segment("#1f1f28", "#7e9cd8", right .. " "),
  }
end

M.glow = function()
  return choices
end

-- New tab button styles are owned by the colorscheme; keep them across
-- tab bar style changes so restore order does not discard them.
local scheme_keys = { "new_tab", "new_tab_hover" }

local function set_style(cfg, style)
  local previous = cfg.tab_bar_style or {}
  for i = 1, #scheme_keys do
    local key = scheme_keys[i]
    if previous[key] ~= nil then
      style = style or {}
      style[key] = previous[key]
    end
  end
  cfg.tab_bar_style = style
end

M.ignite = function(cfg, ctx)
  if ctx.choice.id == "reset" then
    set_style(cfg, nil)
    cfg.use_fancy_tab_bar = nil
    return
  end

  if ctx.choice.id == "native" then
    set_style(cfg, nil)
    cfg.use_fancy_tab_bar = true
    return
  end

  cfg.use_fancy_tab_bar = false
  set_style(cfg, ctx.choice.id == "powerline" and powerline_style() or nil)
end

return M
