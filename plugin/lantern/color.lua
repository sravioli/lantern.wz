---@module "lantern.color"

local config = require "lantern.config"

local M = {}

local function apply_text_style(style)
  return style.intensity
    or (style.italic and "Italic")
    or (style.strikethrough and "Strikethrough")
    or (style.underline ~= nil and style.underline ~= "None" and style.underline)
end

local function tab_segment(parts, background, foreground, text, attribute)
  parts[#parts + 1] = { Background = { Color = background } }
  parts[#parts + 1] = { Foreground = { Color = foreground } }
  if attribute then
    parts[#parts + 1] = { Attribute = attribute }
  end
  parts[#parts + 1] = { Text = text }
end

---Set tab button style in configuration from a Lantern colorscheme.
---@param cfg table
---@param scheme table
function M.set_tab_button(cfg, scheme)
  cfg.tab_bar_style = cfg.tab_bar_style or {}

  local wezterm = require "wezterm"
  local sep = wezterm.nerdfonts or {}
  local right = sep.ple_lower_left_triangle or ""
  local left = sep.ple_upper_right_triangle or ""

  local states = { "new_tab", "new_tab_hover" }
  for i = 1, #states do
    local state = states[i]
    local style = scheme.tab_bar[state]
    local attr = apply_text_style(style)
    local parts = {}

    tab_segment(parts, style.bg_color, scheme.tab_bar.background, right, attr)
    tab_segment(parts, style.bg_color, style.fg_color, " + ", attr)
    tab_segment(parts, style.bg_color, scheme.tab_bar.background, left, attr)

    cfg.tab_bar_style[state] = wezterm.format and wezterm.format(parts) or " + "
  end
end

---Apply a colorscheme to a WezTerm config override table.
---@param cfg table
---@param scheme table
---@param name string
function M.apply_scheme(cfg, scheme, name)
  local opacity = config.get().color.opacity or 1

  cfg.color_scheme = name
  cfg.color_schemes = cfg.color_schemes or {}
  cfg.color_schemes[name] = scheme
  cfg.char_select_bg_color = scheme.brights[6]
  cfg.char_select_fg_color = scheme.background
  cfg.command_palette_bg_color = scheme.brights[6]
  cfg.command_palette_fg_color = scheme.background
  cfg.background = {
    {
      source = { Color = scheme.background },
      width = "100%",
      height = "100%",
      opacity = opacity,
    },
  }
  M.set_tab_button(cfg, scheme)
end

---Load a built-in Lantern colorscheme flame and return its scheme table.
---@param name string
---@return table|nil
function M.scheme(name)
  local ok, flame = pcall(require, "lantern.flames.colorschemes." .. name)
  if ok and flame and flame.scheme then
    return flame.scheme
  end
  return nil
end

return M
