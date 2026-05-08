---@module "lantern.wicks.tab_bar_style"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: tab bar style",
  name = "tab-bar-style",
  sort_by = "label",
  flame_dirs = { { "tab-bar-style" } },
}
