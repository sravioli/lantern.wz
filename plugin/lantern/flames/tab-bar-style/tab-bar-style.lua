---@module "lantern.flames.tab-bar-style.tab-bar-style"

---@class Lantern.Flame
local M = {}

local wezterm = require "wezterm"
local nf = wezterm.nerdfonts or {}

local choices = {
  { id = "native", label = "Native tab bar" },
  { id = "retro", label = "Retro tab bar" },
  { id = "powerline", label = "Powerline tab bar" },
  { id = "reset", label = "Reset" },
}

local function segment(bg, fg, text)
  return wezterm.format {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = text },
  }
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

M.ignite = function(cfg, ctx)
  cfg.tab_bar_style = nil

  if ctx.choice.id == "reset" then
    cfg.use_fancy_tab_bar = nil
    return
  end

  if ctx.choice.id == "native" then
    cfg.use_fancy_tab_bar = true
    return
  end

  cfg.use_fancy_tab_bar = false
  if ctx.choice.id == "powerline" then
    cfg.tab_bar_style = powerline_style()
  end
end

return M
