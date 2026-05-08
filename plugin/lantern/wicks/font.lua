---@module "lantern.wicks.font"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: font",
  name = "fonts",
  flame_dirs = { { "fonts" } },
}
