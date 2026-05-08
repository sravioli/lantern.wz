---@module "lantern.wicks.cursor_style"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: cursor style",
  name = "cursor-style",
  sort_by = "label",
  flame_dirs = { { "cursor-style" } },
}
