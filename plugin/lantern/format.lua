---@module "lantern.format"

local config = require "lantern.config"
local wezterm = require "wezterm"

local M = {}

local named_colors = {
  Black = true,
  Maroon = true,
  Green = true,
  Olive = true,
  Navy = true,
  Purple = true,
  Teal = true,
  Silver = true,
  Grey = true,
  Red = true,
  Lime = true,
  Yellow = true,
  Blue = true,
  Fuchsia = true,
  Aqua = true,
  White = true,
}

local function color_item(kind, color)
  if named_colors[color] then
    return { [kind] = { AnsiColor = color } }
  end
  return { [kind] = { Color = color or "none" } }
end

---@param text string
---@return integer
function M.width(text)
  if wezterm.column_width then
    return wezterm.column_width(text)
  end
  return #tostring(text)
end

---@param parts table
---@return string
function M.render(parts)
  if wezterm.format then
    return wezterm.format(parts)
  end

  local result = {}
  for i = 1, #parts do
    local item = parts[i]
    if item.Text then
      result[#result + 1] = item.Text
    end
  end
  return table.concat(result)
end

---@class Lantern.Layout
---@field parts table[]
local Layout = {}
Layout.__index = Layout

---@return Lantern.Layout
function M.layout()
  return setmetatable({ parts = {} }, Layout)
end

---@param background? string
---@param foreground? string
---@param text string
---@param attributes? table|string
---@return Lantern.Layout
function Layout:append(background, foreground, text, attributes)
  self.parts[#self.parts + 1] = color_item("Background", background)
  self.parts[#self.parts + 1] = color_item("Foreground", foreground)

  if attributes then
    local attr_list = type(attributes) == "table" and attributes or { attributes }
    for i = 1, #attr_list do
      self.parts[#self.parts + 1] = { Attribute = attr_list[i] }
    end
  end

  self.parts[#self.parts + 1] = { Text = text or "" }
  return self
end

---@return string
function Layout:format()
  return M.render(self.parts)
end

---@param desc string
---@param fuzzy boolean
---@return string
function M.description(desc, fuzzy)
  local cfg = config.get()
  return cfg.defaults.format_description(desc, fuzzy, cfg.defaults.icons)
end

return M
