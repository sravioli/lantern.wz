---@module "lantern.wicks.gpu"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: GPU",
  name = "gpus",
  fuzzy = true,
  flame_dirs = { { "gpus" } },
}
