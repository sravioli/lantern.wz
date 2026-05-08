---@module "lantern.flames.gpus.gpus"

local deps = require "lantern.deps"
local wezterm = require "wezterm"

local logger = deps.log.new "Lantern.GPU"
local platform = deps.warp.filesystem.platform().os

---@alias Gpu.BackEnd "Vulkan"|"Metal"|"Gl"|"Dx12"
---@alias Gpu.DeviceType "DiscreteGpu"|"IntegratedGpu"|"Cpu"|"Other"

---@class Lantern.Flame
local M = {}

local function enumerate_gpus()
  if wezterm.gui and wezterm.gui.enumerate_gpus then
    return wezterm.gui.enumerate_gpus()
  end
  return {}
end

local Gpu = {
  VendorMap = {},
  ENUMERATED_GPUS = enumerate_gpus(),
  AVAILABLE_BACKENDS = {
    windows = { "Dx12", "Vulkan", "Gl" },
    linux = { "Vulkan", "Gl" },
    mac = { "Metal" },
  },
}

Gpu._backends = Gpu.AVAILABLE_BACKENDS[platform] or { "Vulkan", "Gl" }
Gpu._preferred_backend = Gpu._backends[1]

for i = 1, #Gpu.ENUMERATED_GPUS do
  local gpu = Gpu.ENUMERATED_GPUS[i]
  local device_table = Gpu[gpu.device_type]
  if not device_table then
    device_table = {}
    Gpu[gpu.device_type] = device_table
  end

  device_table[gpu.backend] = gpu
  Gpu.VendorMap[tostring(gpu.vendor)] = gpu
end

---Return GPU choices formatted for Lantern.
---@return Lantern.Choice[]
M.glow = function()
  local choices = {}
  for i = 1, #Gpu.ENUMERATED_GPUS do
    local gpu = Gpu.ENUMERATED_GPUS[i]
    local label = ("[%s] (%s) %s"):format(gpu.backend, gpu.device_type, gpu.name)
    choices[#choices + 1] = { id = tostring(gpu.vendor), label = label }
  end
  return choices
end

---@param cfg table
---@param opts Lantern.Context
M.ignite = function(cfg, opts)
  local gpu_info = Gpu.VendorMap[tostring(opts.choice.id)]

  if not gpu_info then
    logger:error("selected GPU vendor %s not found", tostring(opts.choice.id))
    return
  end

  cfg.webgpu_preferred_adapter = gpu_info
end

---Automatically choose the best available GPU.
---@return GpuInfo|nil
M.best = function()
  local preferred_order = { "DiscreteGpu", "IntegratedGpu", "Other", "Cpu" }
  local selected_table = nil

  for _, device_type in ipairs(preferred_order) do
    local t = Gpu[device_type]
    if t and next(t) then
      selected_table = t
      break
    end
  end

  if not selected_table then
    logger:error "no GPU adapters found; using default adapter"
    return nil
  end

  local gpu_choice = selected_table[Gpu._preferred_backend]
  if not gpu_choice then
    logger:error("preferred backend %s not available; using first backend", Gpu._preferred_backend)
    local first_backend = next(selected_table)
    gpu_choice = selected_table[first_backend]
  end

  return gpu_choice
end

return M
