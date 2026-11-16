-- Minimal WezTerm config for `scripts/screenshots.sh`: a window with a small
-- bar from mosaic.wz (https://github.com/sravioli/mosaic.wz) in the kanagawa
-- scheme ($LANTERN_KANAGAWA: "wave" dark, "lotus" light) of the kanagawa plugin
-- (https://github.com/kanagawa-community/wezterm) and the scene named by $LANTERN_SCENE open. Settings come from the
-- environment so the script stays the only place that knows the defaults.
local wezterm = require "wezterm"

local repo = assert(os.getenv "LANTERN_REPO", "LANTERN_REPO is not set")
local scene = assert(os.getenv "LANTERN_SCENE", "LANTERN_SCENE is not set")
-- Bar-only scenes: an undecorated one-row window the script crops to the bar.
local bar_only = scene:match "^%s$" ~= nil
for _, name in ipairs { "mosaic", "warp", "log", "warden", "sigil", "ribbon", "memo" } do
  local base = repo .. "/../" .. name .. ".wz/plugin/"
  package.path = base .. "?.lua;" .. base .. "?/init.lua;" .. package.path
end
package.path = repo .. "/plugin/?.lua;" .. repo .. "/plugin/?/init.lua;" .. package.path

local kanagawa = wezterm.plugin.require "https://github.com/kanagawa-community/wezterm"

local lantern = require "lantern.api"
local mosaic = require "mosaic.api"
-- The gpu selector lists the adapters of the machine: show made-up ones.
wezterm.gui = wezterm.gui or {}
wezterm.gui.enumerate_gpus = function()
  local gpus = {}
  local demo =
    { { "Demo Discrete GPU", "DiscreteGpu" }, { "Demo Integrated GPU", "IntegratedGpu" } }
  for i, g in ipairs(demo) do
    for _, backend in ipairs { "Vulkan", "Gl" } do
      gpus[#gpus + 1] = {
        name = g[1],
        backend = backend,
        device_type = g[2],
        device = i,
        vendor = i,
        driver = "demo",
        driver_info = "demo",
      }
    end
  end
  return gpus
end

mosaic.setup {
  preset = "minimal",
  position = "top",
  layout = { left = { "workspace" }, right = { "lantern.scheme", "clock" } },
}

local config = wezterm.config_builder()
config.font = wezterm.font_with_fallback {
  os.getenv "LANTERN_FONT" or "FiraCode Nerd Font",
  "Symbols Nerd Font",
}
config.font_size = tonumber(os.getenv "LANTERN_FONT_SIZE" or 14)
config.initial_cols = tonumber(os.getenv "LANTERN_COLS" or 100)
config.initial_rows = tonumber(os.getenv "LANTERN_ROWS" or 30)
config.enable_wayland = false -- XWayland: KDE draws the frame and title bar
config.window_decorations = "TITLE | RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.enable_scroll_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 24
config.check_for_updates = false
-- The scheme first: mosaic draws the new-tab button in the scheme set when it is applied.
kanagawa.apply_to_config(config, { scheme = os.getenv "LANTERN_KANAGAWA" or "wave" })
mosaic.apply_to_config(config)
lantern.rekindle(config)

if bar_only then
  config.window_decorations = "NONE"
  config.initial_cols = tonumber(os.getenv "LANTERN_BAR_COLS" or 140)
  config.initial_rows = 1 -- the bar plus one row; the script keeps only the bar
  config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
end

-- The title bar names the feature on show.
wezterm.on("format-window-title", function()
  return "lantern: " .. scene
end)

-- Pane content that stays open: fastfetch with a config that prints a logo and
-- colour blocks only, so nothing about the machine the shots are taken on shows.
local demo =
  { "sh", "-c", ("fastfetch -c %q; exec sleep 100000"):format(repo .. "/scripts/fastfetch.jsonc") }

-- scene name -> function(window, pane) that opens it.
local scenes = {
  colorscheme = function(w, p)
    w:perform_action(lantern.light.colorscheme(), p)
  end,
  font = function(w, p)
    w:perform_action(lantern.light.font(), p)
  end,
  font_size = function(w, p)
    w:perform_action(lantern.light.font_size(), p)
  end,
  font_leading = function(w, p)
    w:perform_action(lantern.light.font_leading(), p)
  end,
  gpu = function(w, p)
    w:perform_action(lantern.light.gpu(), p)
  end,
  window_opacity = function(w, p)
    w:perform_action(lantern.light.window_opacity(), p)
  end,
  window_padding = function(w, p)
    w:perform_action(lantern.light.window_padding(), p)
  end,
  cursor_style = function(w, p)
    w:perform_action(lantern.light.cursor_style(), p)
  end,
  inactive_pane_opacity = function(w, p)
    w:perform_action(lantern.light.inactive_pane_opacity(), p)
  end,
  font_ligatures = function(w, p)
    w:perform_action(lantern.light.font_ligatures(), p)
  end,
  tab_bar_style = function(w, p)
    w:perform_action(lantern.light.tab_bar_style(), p)
  end,
}

wezterm.on("gui-startup", function()
  local tab, pane, window = wezterm.mux.spawn_window { args = demo, cwd = wezterm.home_dir }
  tab:set_title "dotfiles"
  -- A split with some output behind the overlay, and two more tabs for the bar.
  if not bar_only then
    pane:split { direction = "Right", args = demo }
  end
  pane:activate()
  for _, title in ipairs { "notes", "build" } do
    window:spawn_tab({ cwd = wezterm.home_dir }):set_title(title)
  end
  tab:activate()
  -- The GUI window exists only after startup returns.
  wezterm.time.call_after(1, function()
    scenes[scene](window:gui_window(), pane)
  end)
end)

return config
