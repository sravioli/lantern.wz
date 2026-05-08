---@module "lantern.wicks.font"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: font",
  name = "fonts",
  flames = core.flames_from_dir { "fonts" },
}
