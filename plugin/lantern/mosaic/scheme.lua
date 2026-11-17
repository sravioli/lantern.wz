---@module "lantern.mosaic.scheme"
---@author sravioli
---@license GNU-GPLv2

---mosaic integration `lantern.scheme`: the active colour scheme name (the
---window override when set, else the configured scheme). mosaic reads this
---file only when a layout names it.
---
---Options (`options["lantern.scheme"]`):
---  icon? string|false  glyph (default: sigil's `Palette`); false hides it

return {
  api = 1,
  new = function(opts)
    local icon = opts.icon
    if icon == nil then
      icon = require("lantern.deps").symbol "Palette"
    end

    return function(window, _, _, config)
      local overrides = window:get_config_overrides() or {}
      local name = overrides.color_scheme or (config and config.color_scheme)
      if not name or name == "" then
        return { enabled = false }
      end
      return {
        enabled = true,
        cond = true,
        can_hide = true,
        -- The scheme only changes through overrides or a reload.
        update = function()
          return name
        end,
        padding = { left = 1 },
        accent = 6, -- colour hint; the preset styles the module
        icon = {
          enabled = icon ~= false and icon ~= "",
          value = icon or "",
          padding = { right = 1 },
        },
        text = { enabled = true, value = name },
      }
    end
  end,
}
