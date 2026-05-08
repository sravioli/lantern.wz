---Minimal WezTerm mock for Lantern unit tests.

local M = {}

M.GLOBAL = {}
M.config_dir = "C:\\wezterm"
M.home_dir = "C:\\Users\\Test"
M.target_triple = "x86_64-pc-windows-msvc"
M._events = {}
M._logs = { info = {}, warn = {}, error = {} }
M._read_dirs = {}
M._read_dir_calls = {}

M.nerdfonts = {
  cod_search = "search",
  cod_search_fuzzy = "fuzzy",
  md_flashlight = "lantern",
  ple_lower_left_triangle = "<",
  ple_upper_right_triangle = ">",
}

M.action = {
  Nop = { type = "Nop" },
  EmitEvent = function(name)
    return { type = "EmitEvent", name = name }
  end,
  InputSelector = function(args)
    return { type = "InputSelector", args = args }
  end,
}

function M.action_callback(fn)
  return { type = "action_callback", fn = fn }
end

function M.on(name, fn)
  M._events[name] = fn
end

function M.format(parts)
  local out = {}
  for i = 1, #parts do
    if parts[i].Text then
      out[#out + 1] = parts[i].Text
    end
  end
  return table.concat(out)
end

function M.column_width(text)
  return #tostring(text)
end

local function normalize_path(path)
  return tostring(path):gsub("\\", "/")
end

function M._set_read_dir(path, entries)
  M._read_dirs[normalize_path(path)] = entries
end

function M.read_dir(path)
  local key = normalize_path(path)
  M._read_dir_calls[key] = (M._read_dir_calls[key] or 0) + 1
  return M._read_dirs[key] or {}
end

function M.log_info(message)
  M._logs.info[#M._logs.info + 1] = message
end

function M.log_warn(message)
  M._logs.warn[#M._logs.warn + 1] = message
end

function M.log_error(message)
  M._logs.error[#M._logs.error + 1] = message
end

M.gui = {
  enumerate_gpus = function()
    return {
      {
        backend = "Dx12",
        device_type = "DiscreteGpu",
        name = "Discrete",
        vendor = 1000,
      },
      {
        backend = "Dx12",
        device_type = "IntegratedGpu",
        name = "Integrated",
        vendor = 2000,
      },
    }
  end,
}

function M.font_with_fallback(spec)
  return { type = "font_with_fallback", spec = spec }
end

function M.font(family, opts)
  return { type = "font", family = family, opts = opts }
end

local function json_escape(value)
  return tostring(value):gsub("\\", "\\\\"):gsub('"', '\\"')
end

local function encode(value)
  if type(value) == "string" then
    return '"' .. json_escape(value) .. '"'
  end
  if type(value) == "number" or type(value) == "boolean" then
    return tostring(value)
  end
  if type(value) == "table" then
    local parts = {}
    for key, item in pairs(value) do
      parts[#parts + 1] = encode(tostring(key)) .. ":" .. encode(item)
    end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  return "null"
end

local function decode_object(content)
  local result = {}
  for wick, body in content:gmatch '"([^"]+)"%s*:%s*{([^}]*)}' do
    result[wick] = {}
    for key, value in body:gmatch '"([^"]+)"%s*:%s*"([^"]*)"' do
      result[wick][key] = value:gsub("\\\\", "\\")
    end
  end
  return result
end

M.serde = {
  json_encode = encode,
  json_decode = decode_object,
}

local function shallow_copy(value)
  if type(value) ~= "table" then
    return value
  end

  local copy = {}
  for key, item in pairs(value) do
    copy[key] = item
  end
  return copy
end

local function deep_copy(value)
  if type(value) ~= "table" then
    return value
  end

  local copy = {}
  for key, item in pairs(value) do
    copy[key] = deep_copy(item)
  end
  return copy
end

local function is_list(value)
  return type(value) == "table" and value[1] ~= nil
end

local function deep_merge(dst, src)
  if type(src) ~= "table" then
    return dst
  end

  for key, value in pairs(src) do
    if type(value) == "table" and type(dst[key]) == "table" and not is_list(value) then
      deep_merge(dst[key], value)
    else
      dst[key] = value
    end
  end

  return dst
end

local mock_log = {}
local MockLogger = {}
MockLogger.__index = MockLogger

function mock_log.new(tag)
  return setmetatable({ tag = tag or "Log" }, MockLogger)
end

function mock_log.setup() end

function MockLogger:log(level, message, ...)
  local level_name = tostring(level):lower()
  local sink = level_name == "error" and "error" or level_name == "warn" and "warn" or "info"
  local ok, formatted = pcall(string.format, message, ...)
  M._logs[sink][#M._logs[sink] + 1] = ("[%s] %s"):format(self.tag, ok and formatted or message)
end

function MockLogger:debug(message, ...)
  self:log("info", message, ...)
end

function MockLogger:info(message, ...)
  self:log("info", message, ...)
end

function MockLogger:warn(message, ...)
  self:log("warn", message, ...)
end

function MockLogger:error(message, ...)
  self:log("error", message, ...)
end

local mock_cache = {}

function mock_cache.namespace(name)
  local prefix = name .. ":"
  return {
    compute = function(key, fn, ...)
      M.GLOBAL.__memo_cache = M.GLOBAL.__memo_cache or {}
      local cache_key = prefix .. tostring(key)
      if M.GLOBAL.__memo_cache[cache_key] == nil then
        M.GLOBAL.__memo_cache[cache_key] = fn(...)
      end
      return M.GLOBAL.__memo_cache[cache_key]
    end,
  }
end

local MockStore = {}
MockStore.__index = MockStore

local function store_slot(store_path)
  local key = "__memo_state_" .. tostring(store_path):gsub("[^%w_%-%.]", "_")
  M.GLOBAL[key] = M.GLOBAL[key] or { loaded = false, data = {} }
  return M.GLOBAL[key]
end

local function ensure_store_loaded(store)
  if not store._slot.loaded then
    store:load()
  end
end

function MockStore:get(key)
  ensure_store_loaded(self)
  return self._slot.data[key]
end

function MockStore:set(key, value)
  ensure_store_loaded(self)
  self._slot.data[key] = deep_copy(value)
  self:save()
end

function MockStore:delete(key)
  ensure_store_loaded(self)
  self._slot.data[key] = nil
  self:save()
end

function MockStore:clear()
  ensure_store_loaded(self)
  for key in pairs(self._slot.data) do
    self._slot.data[key] = nil
  end
  self:save()
end

function MockStore:load()
  self._slot.loaded = true
  local fh = io.open(self._path, "r")
  if not fh then
    return
  end

  local content = fh:read "*a"
  fh:close()
  if not content or content == "" then
    return
  end

  self._slot.data = M.serde.json_decode(content)
end

function MockStore:save()
  local fh = io.open(self._path, "w")
  if not fh then
    return
  end

  fh:write(M.serde.json_encode(self._slot.data))
  fh:close()
end

function MockStore:restore()
  ensure_store_loaded(self)
  return shallow_copy(self._slot.data)
end

local mock_memo = {
  cache = mock_cache,
  state = {
    new = function(opts)
      return setmetatable({ _path = opts.path, _slot = store_slot(opts.path) }, MockStore)
    end,
  },
}

local mock_warp = {
  filesystem = {
    platform = function()
      return { os = "windows", is_win = true, is_linux = false, is_mac = false }
    end,
  },
  path = {
    separator = "\\",
    concat = function(...)
      return table.concat({ ... }, "\\")
    end,
    normalize = normalize_path,
  },
  string = {
    width = function(text)
      return M.column_width(text)
    end,
  },
  table = {
    copy = shallow_copy,
    deepcopy = deep_copy,
    merge = function(_, dst, ...)
      for i = 1, select("#", ...) do
        deep_merge(dst, select(i, ...))
      end
      return dst
    end,
  },
}

M.plugin = {
  list = function()
    return {
      { url = "https://github.com/sravioli/lantern.wz", plugin_dir = "C:\\lantern.wz" },
    }
  end,
  require = function(url)
    if url:find("log.wz", 1, true) then
      return mock_log
    end
    if url:find("memo.wz", 1, true) then
      return mock_memo
    end
    if url:find("warp.wz", 1, true) then
      return mock_warp
    end
    error("unknown plugin " .. tostring(url))
  end,
}

function M._reset()
  M.GLOBAL = {}
  M._events = {}
  M._logs = { info = {}, warn = {}, error = {} }
  M._read_dirs = {}
  M._read_dir_calls = {}
end

package.loaded["wezterm"] = M

return M
