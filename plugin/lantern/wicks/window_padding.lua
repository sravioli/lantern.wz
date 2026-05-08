---@module "lantern.wicks.window_padding"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: window padding",
  name = "window-padding",
  sort_by = "label",
  flame_dirs = { { "window-padding" } },
}
