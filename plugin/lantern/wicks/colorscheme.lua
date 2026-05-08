---@module "lantern.wicks.colorscheme"

local core = require "lantern.core"
local format = require "lantern.format"

local function fallback_foreground(ctx)
  local cfg = ctx.window and ctx.window:effective_config() or {}
  local scheme_name = cfg.color_scheme
  local schemes = cfg.color_schemes or {}
  local scheme = scheme_name and schemes[scheme_name]
  return scheme and scheme.foreground or "#ffffff"
end

return core.new_wick {
  title = "Lantern: colorscheme",
  name = "colorschemes",
  flame_dirs = { { "colorschemes" } },

  format_choices = function(internal_choices, ctx)
    local choices = {}
    local max_label_len = 0

    for _, item in pairs(internal_choices) do
      local label = tostring(item.choice.label or item.choice.id)
      local len = format.width(label)
      max_label_len = len > max_label_len and len or max_label_len
    end

    local fg = fallback_foreground(ctx)

    for _, item in pairs(internal_choices) do
      local id = item.choice.id
      local label = tostring(item.choice.label or id)
      local colors = item.flame.scheme
      local layout = format.layout()

      layout:append(nil, fg, label)
      layout:append(nil, fg, (" "):rep((max_label_len - format.width(label)) + 2))

      for i = 1, #colors.ansi do
        local color = colors.ansi[i]
        layout:append(color, color, "  ")
      end

      layout:append(nil, nil, "   ")

      for i = 1, #colors.brights do
        local color = colors.brights[i]
        layout:append(color, color, "  ")
      end

      choices[#choices + 1] = { id = id, label = layout:format() }
    end

    return choices
  end,

  comp = function(a, b)
    return a.id < b.id
  end,
}
