---@module "lantern.wicks.inactive_pane_opacity"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: inactive pane opacity",
  name = "inactive-pane-opacity",
  sort_by = "label",
  flame_dirs = { { "inactive-pane-opacity" } },
}
