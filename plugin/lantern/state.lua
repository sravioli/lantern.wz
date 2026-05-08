---@module "lantern.state"

local config = require "lantern.config"
local wezterm = require "wezterm"

local M = {}

local loaded_path
local loaded = false
local data = {}

local function log_warn(message)
  if wezterm.log_warn then
    wezterm.log_warn("[lantern.state] " .. message)
  end
end

local function path_sep()
  -- selene: allow(incorrect_standard_library_use)
  return package.config:sub(1, 1)
end

local function join(...)
  local sep = path_sep()
  local parts = { ... }
  local result = tostring(parts[1] or "")
  for i = 2, #parts do
    local part = tostring(parts[i] or "")
    if result:sub(-1) == sep then
      result = result .. part
    else
      result = result .. sep .. part
    end
  end
  return result
end

local function state_dir()
  local sep = path_sep()
  local dir
  if sep == "\\" then
    dir = os.getenv "LOCALAPPDATA" or os.getenv "APPDATA"
    if dir then
      dir = join(dir, "wezterm")
    end
  else
    local xdg = os.getenv "XDG_STATE_HOME"
    if xdg then
      dir = join(xdg, "wezterm")
    else
      local home = os.getenv "HOME"
      if home then
        dir = join(home, ".local", "state", "wezterm")
      end
    end
  end

  return dir or wezterm.config_dir or "."
end

---@param filename string
---@return string
local function default_state_path(filename)
  return join(state_dir(), filename)
end

local function active_path()
  local cfg = config.get()
  return cfg.persistence.path or default_state_path "lantern-state.json"
end

local function legacy_path()
  local cfg = config.get()
  return cfg.persistence.legacy_path or default_state_path "picker-state.json"
end

local function read_file(path)
  local fh = io.open(path, "r")
  if not fh then
    return nil
  end

  local content = fh:read "*a"
  fh:close()
  return content
end

local function write_file(path, content)
  local fh, err = io.open(path, "w")
  if not fh then
    log_warn(("unable to write %s: %s"):format(path, tostring(err)))
    return false
  end

  fh:write(content)
  fh:close()
  return true
end

local function decode_file(path)
  if not wezterm.serde or not wezterm.serde.json_decode then
    return {}
  end

  local content = read_file(path)
  if not content or content == "" then
    return {}
  end

  local ok, decoded = pcall(wezterm.serde.json_decode, content)
  if not ok or type(decoded) ~= "table" then
    log_warn(("invalid JSON in %s"):format(path))
    return {}
  end

  return decoded
end

local function encode(value)
  if not wezterm.serde or not wezterm.serde.json_encode then
    return nil
  end

  local ok, encoded = pcall(wezterm.serde.json_encode, value)
  if not ok then
    log_warn "unable to encode state"
    return nil
  end
  return encoded
end

local function migrate_legacy_entry(entry)
  if type(entry) ~= "table" then
    return entry
  end

  local migrated = {}
  for key, value in pairs(entry) do
    migrated[key] = value
  end

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
  local path = active_path()
  if loaded and loaded_path == path then
    return
  end

  loaded = true
  loaded_path = path
  data = decode_file(path)

  if next(data) ~= nil then
    return
  end

  local legacy = decode_file(legacy_path())
  if next(legacy) == nil then
    return
  end

  data = migrate_legacy_state(legacy)
  M.flush()
end

---Persist current state to disk.
function M.flush()
  if not config.get().persistence.enabled then
    return
  end

  local encoded = encode(data)
  if encoded then
    write_file(active_path(), encoded)
  end
end

---@param wick_name string
---@param entry table
function M.save(wick_name, entry)
  if not config.get().persistence.enabled then
    return
  end

  ensure_loaded()
  data[wick_name] = entry
  M.flush()
end

---@param wick_name string
---@return table|nil
function M.get(wick_name)
  ensure_loaded()
  return data[wick_name]
end

---@param wick_name? string
function M.clear(wick_name)
  ensure_loaded()

  if wick_name then
    data[wick_name] = nil
  else
    for key in pairs(data) do
      data[key] = nil
    end
  end

  M.flush()
end

---@return table
function M.all()
  ensure_loaded()
  local copy = {}
  for key, value in pairs(data) do
    copy[key] = value
  end
  return copy
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
  loaded_path = nil
  loaded = false
  data = {}
end

return M
