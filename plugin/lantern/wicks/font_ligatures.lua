---@module "lantern.wicks.font_ligatures"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: font ligatures",
  name = "font-ligatures",
  sort_by = "label",
  flame_dirs = { { "font-ligatures" } },
}
