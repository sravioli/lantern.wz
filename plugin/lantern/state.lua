---@module "lantern.state"

local config = require "lantern.config"
local deps = require "lantern.deps"
local wezterm = require "wezterm"

local logger = deps.log.new "Lantern.State"
local path = deps.warp.path
local state = deps.memo.state
local tbl = deps.warp.table

local M = {}

local active_store
local active_store_path
local legacy_store
local legacy_store_path

local function state_dir()
  local dir
  if path.separator == "\\" then
    dir = os.getenv "LOCALAPPDATA" or os.getenv "APPDATA"
    if dir then
      dir = path.concat(dir, "wezterm")
    end
  else
    local xdg = os.getenv "XDG_STATE_HOME"
    if xdg then
      dir = path.concat(xdg, "wezterm")
    else
      local home = os.getenv "HOME"
      if home then
        dir = path.concat(home, ".local", "state", "wezterm")
      end
    end
  end

  return dir or wezterm.config_dir or "."
end

---@param filename string
---@return string
local function default_state_path(filename)
  return path.concat(state_dir(), filename)
end

local function active_path()
  local cfg = config.get()
  return cfg.persistence.path or default_state_path "lantern-state.json"
end

local function legacy_path()
  local cfg = config.get()
  return cfg.persistence.legacy_path or default_state_path "picker-state.json"
end

---@param store_path string
---@return memo.state.Store
local function new_store(store_path)
  return state.new {
    path = store_path,
    auto_load = true,
    auto_save = true,
    async = false,
  }
end

---@return memo.state.Store
local function get_active_store()
  local store_path = active_path()
  if not active_store or active_store_path ~= store_path then
    active_store_path = store_path
    active_store = new_store(store_path)
  end
  return active_store
end

---@return memo.state.Store
local function get_legacy_store()
  local store_path = legacy_path()
  if not legacy_store or legacy_store_path ~= store_path then
    legacy_store_path = store_path
    legacy_store = new_store(store_path)
  end
  return legacy_store
end

local function migrate_legacy_entry(entry)
  if type(entry) ~= "table" then
    return entry
  end

  local migrated = tbl.copy(entry)
  if type(migrated.module) == "string" then
    migrated.module = migrated.module:gsub("^picker%.assets%.", "lantern.flames.")
  end

  return migrated
end

local function migrate_legacy_state(legacy)
  local migrated = {}
  for wick_name, entry in pairs(legacy) do
    migrated[wick_name] = migrate_legacy_entry(entry)
  end
  return migrated
end

local function ensure_loaded()
  local store = get_active_store()
  local data = store:restore()

  if next(data) ~= nil then
    return store
  end

  local legacy = get_legacy_store():restore()
  if next(legacy) == nil then
    return store
  end

  local migrated = migrate_legacy_state(legacy)
  for wick_name, entry in pairs(migrated) do
    store:set(wick_name, entry)
  end
  logger:info("migrated legacy picker state into %s", active_path())

  return store
end

---Persist current state to disk.
function M.flush()
  if not config.get().persistence.enabled then
    return
  end

  get_active_store():save()
end

---@param wick_name string
---@param entry table
function M.save(wick_name, entry)
  if not config.get().persistence.enabled then
    return
  end

  ensure_loaded():set(wick_name, entry)
end

---@param wick_name string
---@return table|nil
function M.get(wick_name)
  return ensure_loaded():get(wick_name)
end

---@param wick_name? string
function M.clear(wick_name)
  if not config.get().persistence.enabled then
    return
  end

  local store = ensure_loaded()
  if wick_name then
    store:delete(wick_name)
  else
    store:clear()
  end
end

---@return table
function M.all()
  return ensure_loaded():restore()
end

---@return string
function M.path()
  return active_path()
end

---@return string
function M.legacy_path()
  return legacy_path()
end

function M._reset_for_tests()
  active_store = nil
  active_store_path = nil
  legacy_store = nil
  legacy_store_path = nil
end

return M
