---@module "lantern.config"

local tbl = require("lantern.deps").warp.table

---@class Lantern.Config
---@field log Lantern.LogConfig
---@field persistence Lantern.PersistenceConfig
---@field defaults Lantern.DefaultConfig
---@field default_font table
---@field color Lantern.ColorConfig
local M = {}

---@class Lantern.LogConfig
---@field enabled boolean

---@class Lantern.PersistenceConfig
---@field enabled boolean
---@field path? string
---@field legacy_path? string
---@field reset_behavior "clear"|"persist"

---@class Lantern.ColorConfig
---@field opacity number

---@class Lantern.DefaultConfig
---@field title string
---@field sort_by string
---@field fuzzy boolean
---@field description string
---@field fuzzy_description string
---@field alphabet string
---@field icons Lantern.Icons
---@field comp fun(sort_by: string): fun(a: Lantern.Choice, b: Lantern.Choice): boolean
---@field format_choices Lantern.FormatChoices
---@field format_description Lantern.FormatDescription

---@alias Lantern.FormatChoices fun(choices: table, ctx: Lantern.BuildContext): Lantern.Choice[]
---@alias Lantern.FormatDescription fun(desc: string, fuzzy: boolean, icons: Lantern.Icons): string

---@class Lantern.Icons
---@field lantern string
---@field fuzzy { ico: string, punct: string }
---@field exact { ico: string, punct: string }

local wezterm = require "wezterm"
local nf = wezterm.nerdfonts or {}

local function default_comp(sort_by)
  return function(a, b)
    local a_label = tostring(a.label or "")
    local b_label = tostring(b.label or "")
    local a_is_reset = tostring(a.id):lower() == "reset" or a_label:lower():find("reset", 1, true)
    local b_is_reset = tostring(b.id):lower() == "reset" or b_label:lower():find("reset", 1, true)

    if a_is_reset ~= b_is_reset then
      return a_is_reset
    end

    return tostring(a[sort_by] or "") < tostring(b[sort_by] or "")
  end
end

local defaults = {
  log = {
    enabled = true,
  },

  persistence = {
    enabled = true,
    path = nil,
    legacy_path = nil,
    reset_behavior = "clear",
  },

  default_font = {
    font_size = 10,
  },

  color = {
    opacity = 1,
  },

  defaults = {
    title = "Light a wick",
    sort_by = "id",
    fuzzy = true,
    description = "Select a flame.",
    fuzzy_description = "Light",
    alphabet = "1234567890abcdefghilmnopqrstuvwxyz",

    icons = {
      lantern = nf.md_lan or nf.md_flashlight or nf.md_pickaxe or "",
      fuzzy = {
        ico = nf.cod_search_fuzzy or "",
        punct = "❭",
      },
      exact = {
        ico = nf.cod_search or "",
        punct = ":",
      },
    },

    comp = default_comp,

    format_choices = function(internal_choices, _)
      local choices = {}
      for _, item in pairs(internal_choices) do
        choices[#choices + 1] = { id = item.choice.id, label = item.choice.label }
      end
      return choices
    end,

    format_description = function(desc, fuzzy, icons)
      local fmt = "%s %s%s "
      if fuzzy then
        return fmt:format(icons.fuzzy.ico, desc, icons.fuzzy.punct)
      end
      return fmt:format(icons.exact.ico, desc, icons.exact.punct)
    end,
  },
}

local config = defaults

---Merge user configuration into Lantern defaults.
---@param opts? table
---@return Lantern.Config
function M.setup(opts)
  config = tbl.merge("force", tbl.deepcopy(defaults), opts or {})
  return config
end

---Return the active Lantern configuration.
---@return Lantern.Config
function M.get()
  return config
end

---@return Lantern.Config
function M.defaults()
  return tbl.deepcopy(defaults)
end

return M
