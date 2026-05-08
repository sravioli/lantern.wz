---@module "lantern.wicks.font_size"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: font size",
  name = "font-sizes",
  sort_by = "label",
  flames = {
    "lantern.flames.font-sizes.font-sizes",
  },
}
