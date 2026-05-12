---@module "lantern.core"

local config = require "lantern.config"
local deps = require "lantern.deps"
local meta = require "lantern.meta"
local state = require "lantern.state"
local wezterm = require "wezterm"

-- selene: allow(incorrect_standard_library_use)
local tunpack = unpack or table.unpack
local cache = deps.memo.cache.namespace "lantern.flame_dirs"
local logger = deps.log.new "Lantern"
local warp_path = deps.warp.path
local tbl = deps.warp.table
local FLAME_DIR_CACHE_VERSION = "v4"

---@class Lantern.Choice
---@field id string
---@field label? string

---@class Lantern.Context
---@field window? table
---@field pane? table
---@field choice Lantern.Choice
---@field wick? Lantern.Wick

---@class Lantern.Flame
---@field glow fun(ctx?: Lantern.BuildContext): Lantern.Choice|Lantern.Choice[]|string|number
---@field ignite fun(config: table, ctx: Lantern.Context)

---@class Lantern.InternalChoice
---@field flame Lantern.Flame
---@field module_path? string
---@field choice Lantern.Choice

---@class Lantern.BuildContext
---@field window table
---@field pane table

---@class Lantern.WickSpec
---@field name? string
---@field title? string
---@field flames? table[]
---@field flame_dirs? Lantern.FlameDir[]
---@field sort_by? string
---@field fuzzy? boolean
---@field alphabet? string
---@field description? string
---@field fuzzy_description? string
---@field persist? boolean
---@field restore_after? string|string[]
---@field restore_priority? number
---@field comp? fun(a: Lantern.Choice, b: Lantern.Choice): boolean
---@field format_choices? Lantern.FormatChoices
---@field format_description? Lantern.FormatDescription

---@class Lantern.Wick
local Wick = {}
Wick.__index = Wick

---@alias Lantern.FlameDir string|string[]

local M = {
  wicks = {},
}

local function log(level, message, ...)
  if not config.get().log.enabled then
    return
  end

  local fn = logger[level]
  if type(fn) == "function" then
    fn(logger, message, ...)
  else
    logger:log(level, message, ...)
  end
end

local function normalize_path(value)
  return warp_path.normalize(value)
end

local function starts_with(value, prefix)
  return value:sub(1, #prefix) == prefix
end

local function path_to_module(path)
  local normalized = normalize_path(path):gsub("%.lua$", "")
  local config_dir = wezterm.config_dir and normalize_path(wezterm.config_dir)
  local plugin_dir = meta.plugin_dir() and normalize_path(meta.plugin_dir())

  if config_dir and starts_with(normalized, config_dir .. "/") then
    return normalized:sub(#config_dir + 2):gsub("/", ".")
  end

  if plugin_dir then
    local plugin_prefix = plugin_dir .. "/plugin/"
    if starts_with(normalized, plugin_prefix) then
      return normalized:sub(#plugin_prefix + 1):gsub("/", ".")
    end
  end

  return normalized:gsub("/", ".")
end

---@param dir_segments string[]
---@return string|nil
local function plugin_flame_dir(dir_segments)
  return meta.plugin_path("plugin", "lantern", "flames", tunpack(dir_segments))
end

---@param dir Lantern.FlameDir
---@return string|nil
local function resolve_flame_dir(dir)
  if type(dir) == "table" then
    return plugin_flame_dir(dir)
  end

  return dir
end

---@param item Lantern.Choice|table|string|number
---@return Lantern.Choice
local function normalize_choice(item)
  if type(item) == "table" then
    item.id = tostring(item.id)
    if item.label ~= nil then
      item.label = tostring(item.label)
    end
    return item
  end

  return { id = tostring(item), label = tostring(item) }
end

local function is_array(item)
  return type(item) == "table" and item[1] ~= nil
end

---@param value? string|string[]
---@return string[]
local function normalize_string_list(value)
  if type(value) == "string" then
    return { value }
  end

  local result = {}
  if type(value) == "table" then
    for i = 1, #value do
      if type(value[i]) == "string" then
        result[#result + 1] = value[i]
      end
    end
  end

  return result
end

local function flame_glow(flame, ctx)
  local glow = flame.glow or flame.get
  if type(glow) ~= "function" then
    return nil
  end
  return glow(ctx)
end

local function flame_ignite(flame, cfg, ctx)
  local ignite = flame.ignite or flame.pick
  if type(ignite) == "function" then
    ignite(cfg, ctx)
  end
end

local function require_flame(spec)
  if type(spec) == "string" then
    return require(spec), spec
  end

  return spec, spec.module_path
end

local function glob_lua_files(path)
  if not wezterm.glob then
    return {}
  end

  local pattern = normalize_path(path):gsub("/+$", "") .. "/*.lua"
  local result = wezterm.glob(pattern)
  if type(result) == "table" then
    return result
  end

  return {}
end

local function read_dir(path)
  if wezterm.read_dir then
    local entries = wezterm.read_dir(path)
    if type(entries) == "table" and #entries > 0 then
      return entries
    end
  end

  local entries = glob_lua_files(path)
  if #entries > 0 then
    return entries
  end

  return {}
end

---@param resolved string
---@return string[]
local function discover_flame_specs(resolved)
  local paths = read_dir(resolved)
  table.sort(paths)

  local discovered = {}
  for i = 1, #paths do
    if paths[i]:match "%.lua$" then
      discovered[#discovered + 1] = path_to_module(paths[i])
    end
  end

  if #discovered == 0 then
    log("warn", "no flame modules discovered in %s", resolved)
  end

  return discovered
end

---@param dir Lantern.FlameDir
---@return string[]
local function flame_specs_from_dir(dir)
  local resolved = resolve_flame_dir(dir)
  if not resolved then
    return {}
  end

  local cache_key = FLAME_DIR_CACHE_VERSION .. ":" .. normalize_path(resolved)
  local specs = cache.get(cache_key)
  if type(specs) == "table" and #specs > 0 then
    return tbl.copy(specs)
  end

  if specs ~= nil then
    cache.delete(cache_key)
  end

  specs = discover_flame_specs(resolved)
  if #specs > 0 then
    cache.set(cache_key, specs, { force = true })
  end

  return tbl.copy(specs)
end

---@param dirs Lantern.FlameDir[]
---@return string[]
local function flame_specs_from_dirs(dirs)
  local specs = {}
  if not dirs then
    return specs
  end

  for i = 1, #dirs do
    local dir_specs = flame_specs_from_dir(dirs[i])
    for j = 1, #dir_specs do
      specs[#specs + 1] = dir_specs[j]
    end
  end

  return specs
end

---@param opts Lantern.WickSpec
---@return Lantern.Wick
function M.new_wick(opts)
  local cfg = config.get()
  local pick_opt = function(value, default)
    if value ~= nil then
      return value
    end
    return default
  end

  local self = setmetatable({}, Wick)
  self.title = opts.title or cfg.defaults.title
  self._name = opts.name
  self._choices = {}
  self._initialized = false
  self._event_registered = false
  self._flames = opts.flames or {}
  self._flame_dirs = opts.flame_dirs or {}

  self.sort_by = opts.sort_by or cfg.defaults.sort_by
  self.fuzzy = pick_opt(opts.fuzzy, cfg.defaults.fuzzy)
  self.alphabet = pick_opt(opts.alphabet, cfg.defaults.alphabet)
  self.description = pick_opt(opts.description, cfg.defaults.description)
  self.fuzzy_description = pick_opt(opts.fuzzy_description, cfg.defaults.fuzzy_description)
  self.persist = pick_opt(opts.persist, cfg.persistence.enabled)
  self.restore_after = normalize_string_list(opts.restore_after)
  self.restore_priority = opts.restore_priority or 0

  self.comp = opts.comp or cfg.defaults.comp(self.sort_by)
  self.format_choices = opts.format_choices or cfg.defaults.format_choices
  self.format_description = opts.format_description or cfg.defaults.format_description

  return self
end

---@param flame_spec string|Lantern.Flame|table
function Wick:register(flame_spec)
  local flame, module_path = require_flame(flame_spec)
  local result = flame_glow(flame)

  if result == nil then
    log("warn", "wick %s skipped flame without glow()", self._name)
    return
  end

  local items = is_array(result) and result or { result }
  for i = 1, #items do
    local choice = normalize_choice(items[i])
    self._choices[choice.id] = {
      flame = flame,
      module_path = module_path,
      choice = { id = choice.id, label = choice.label },
    }
  end
end

function Wick:_initialize()
  if self._initialized then
    return
  end

  local flame_specs = {}
  for i = 1, #self._flames do
    flame_specs[#flame_specs + 1] = self._flames[i]
  end

  local dir_specs = flame_specs_from_dirs(self._flame_dirs)
  for i = 1, #dir_specs do
    flame_specs[#flame_specs + 1] = dir_specs[i]
  end

  for i = 1, #flame_specs do
    local ok, err = pcall(function()
      self:register(flame_specs[i])
    end)
    if not ok then
      log("error", "wick %s failed to register flame: %s", self._name, tostring(err))
    end
  end

  self._initialized = true
end

---@param cfg table
---@param ctx Lantern.Context
function Wick:select(cfg, ctx)
  self:_initialize()

  local internal = self._choices[ctx.choice.id]
  if not internal then
    log("error", "%s is not defined for wick %s", ctx.choice.id, self._name)
    return
  end

  ctx.wick = self
  flame_ignite(internal.flame, cfg, ctx)

  if self.persist then
    local id_lower = tostring(ctx.choice.id):lower()
    local label_lower = tostring(ctx.choice.label or ""):lower()
    local is_reset = id_lower == "reset" or label_lower == "reset"

    if is_reset and config.get().persistence.reset_behavior == "clear" then
      state.clear(self._name)
    else
      state.save(self._name, {
        id = ctx.choice.id,
        module = internal.module_path,
        wick = self._name,
      })
    end
  end
end

---@return table
function Wick:light()
  local event_name = "lantern:light:" .. self._name

  if not self._event_registered then
    wezterm.on(event_name, function(window, pane)
      self:_initialize()

      local ctx = { window = window, pane = pane }
      local choices = self.format_choices(self._choices, ctx)
      table.sort(choices, self.comp)

      window:perform_action(
        wezterm.action.InputSelector {
          action = wezterm.action_callback(function(inner_window, _, id, label)
            if not id and not label then
              log("info", "wick %s cancelled", self._name)
              return
            end

            local overrides = inner_window:get_config_overrides() or {}
            self:select(overrides, {
              window = window,
              pane = pane,
              choice = { id = id, label = label },
            })
            window:set_config_overrides(overrides)
          end),
          title = self.title,
          choices = choices,
          fuzzy = self.fuzzy,
          description = self.format_description(
            self.description,
            self.fuzzy,
            config.get().defaults.icons
          ),
          fuzzy_description = self.format_description(
            self.fuzzy_description,
            self.fuzzy,
            config.get().defaults.icons
          ),
          alphabet = self.alphabet,
        },
        pane
      )
    end)
    self._event_registered = true
  end

  return wezterm.action.EmitEvent(event_name)
end

---@param name string
---@param spec Lantern.WickSpec|Lantern.Wick
---@return Lantern.Wick
function M.add_wick(name, spec)
  local wick = getmetatable(spec) == Wick and spec or M.new_wick(spec)
  wick._name = wick._name or name
  M.wicks[name] = wick
  return wick
end

---@param name string
---@return Lantern.Wick|nil
function M.get_wick(name)
  return M.wicks[name]
end

---@param name string
---@return table
function M.light(name)
  local wick = M.get_wick(name)
  if not wick then
    log("error", "unknown wick: %s", tostring(name))
    return wezterm.action.Nop
  end
  return wick:light()
end

---@param entries table
---@param wick_name string
---@return Lantern.Wick|nil
local function restore_wick(entries, wick_name)
  local entry = entries[wick_name]
  if type(entry) ~= "table" then
    return nil
  end

  return M.get_wick(entry.wick or wick_name)
end

---@param entries table
---@param wick_name string
---@return number
local function restore_priority(entries, wick_name)
  local wick = restore_wick(entries, wick_name)
  return wick and wick.restore_priority or 0
end

---@param entries table
---@return string[]
local function sorted_rekindle_wicks(entries)
  local names = {}
  local exists = {}

  for wick_name, entry in pairs(entries) do
    if type(entry) == "table" and entry.id then
      names[#names + 1] = wick_name
      exists[wick_name] = true
    end
  end

  table.sort(names, function(a, b)
    local a_priority = restore_priority(entries, a)
    local b_priority = restore_priority(entries, b)
    if a_priority ~= b_priority then
      return a_priority < b_priority
    end
    return a < b
  end)

  local sorted = {}
  local visiting = {}
  local visited = {}

  local function visit(wick_name)
    if visited[wick_name] then
      return
    end

    if visiting[wick_name] then
      log("warn", "restore dependency cycle detected at wick %s", wick_name)
      return
    end

    visiting[wick_name] = true

    local wick = restore_wick(entries, wick_name)
    local after = wick and wick.restore_after or {}
    for i = 1, #after do
      if exists[after[i]] then
        visit(after[i])
      end
    end

    visiting[wick_name] = nil
    visited[wick_name] = true
    sorted[#sorted + 1] = wick_name
  end

  for i = 1, #names do
    visit(names[i])
  end

  return sorted
end

---@param cfg? table
---@return table
function M.rekindle(cfg)
  local restored = cfg or {}
  local entries = state.reload()

  local function rekindle_entry(wick_name, entry)
    if type(entry) == "table" and entry.id then
      local ok = false
      local module_err = nil

      if entry.module then
        local require_ok, flame = pcall(require, entry.module)
        if require_ok and flame then
          flame_ignite(flame, restored, {
            choice = { id = entry.id, label = entry.label },
          })
          ok = true
        else
          module_err = flame
        end
      end

      if not ok then
        local wick = M.get_wick(entry.wick or wick_name)
        if wick then
          wick:select(restored, { choice = { id = entry.id, label = entry.label } })
        elseif entry.module then
          log(
            "warn",
            "unable to rekindle wick %s from module %s: %s",
            wick_name,
            tostring(entry.module),
            tostring(module_err)
          )
        else
          log("warn", "clearing stale wick %s; no module recorded", wick_name)
          state.clear(wick_name)
        end
      end
    end
  end

  for _, wick_name in ipairs(sorted_rekindle_wicks(entries)) do
    rekindle_entry(wick_name, entries[wick_name])
  end

  return restored
end

---Return cached flame module paths from one directory.
---
---Pass a string for an absolute/custom directory, or a string array for a
---built-in Lantern flame directory under `plugin/lantern/flames`.
---@param dir Lantern.FlameDir
---@return string[]
function M.flames_from_dir(dir)
  return flame_specs_from_dir(dir)
end

---Return cached flame module paths from multiple directories.
---@param dirs Lantern.FlameDir[]
---@return string[]
function M.flames_from_dirs(dirs)
  return flame_specs_from_dirs(dirs)
end

---@param dir_segments string[]
---@return string|nil
function M.plugin_flame_dir(dir_segments)
  return plugin_flame_dir(dir_segments)
end

return M
