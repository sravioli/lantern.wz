---Minimal WezTerm mock for Lantern unit tests.

local M = {}

M.GLOBAL = {}
M.config_dir = "C:\\wezterm"
M.home_dir = "C:\\Users\\Test"
M._events = {}
M._logs = { info = {}, warn = {}, error = {} }

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

function M.read_dir(_)
  return {}
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

M.plugin = {
  list = function()
    return {
      { url = "https://github.com/sravioli/lantern.wz", plugin_dir = "C:\\lantern.wz" },
    }
  end,
}

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

function M._reset()
  M.GLOBAL = {}
  M._events = {}
  M._logs = { info = {}, warn = {}, error = {} }
end

package.loaded["wezterm"] = M

return M
