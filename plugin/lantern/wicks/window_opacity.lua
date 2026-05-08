---@module "lantern.wicks.window_opacity"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: window opacity",
  name = "window-opacity",
  sort_by = "label",
  flame_dirs = { { "window-opacity" } },
}
