---@module "lantern.wicks.font_leading"

local core = require "lantern.core"

return core.new_wick {
  title = "Lantern: font leading",
  name = "font-leadings",
  flames = core.flames_from_dir { "font-leadings" },
}
