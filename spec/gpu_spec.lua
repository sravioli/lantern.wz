---@diagnostic disable: undefined-global

package.path = "spec/support/?.lua;" .. package.path
local wezterm = require "mock_wezterm"

describe("GPU discovery", function()
  local enumerate, calls
  local state_path = (os.getenv "TEMP" or ".") .. "/lantern-gpu-test.json"
  local legacy_path = state_path .. ".legacy"

  before_each(function()
    for name in pairs(package.loaded) do
      if name:match "^lantern" then
        package.loaded[name] = nil
      end
    end
    wezterm._reset()
    wezterm._set_read_dir("C:/lantern.wz/plugin/lantern/flames/gpus", {
      "C:/lantern.wz/plugin/lantern/flames/gpus/gpus.lua",
    })
    enumerate = wezterm.gui.enumerate_gpus
    calls = 0
    wezterm.gui.enumerate_gpus = function()
      calls = calls + 1
      return enumerate()
    end
    os.remove(state_path)
    os.remove(legacy_path)
  end)

  -- selene: allow(undefined_variable)
  after_each(function()
    wezterm.gui.enumerate_gpus = enumerate
    os.remove(state_path)
    os.remove(legacy_path)
  end)

  local function lantern_with_state()
    local lantern = require "lantern.api"
    lantern.setup { persistence = { path = state_path, legacy_path = legacy_path } }
    return lantern
  end

  it("does not enumerate when loading GPU module or creating picker action", function()
    local lantern = lantern_with_state()
    lantern.gpu()
    lantern.light.gpu()
    lantern.rekindle()
    assert.equal(0, calls)
  end)

  it("enumerates once when choices or best adapter are requested", function()
    local gpu = require "lantern.flames.gpus.gpus"
    assert.equal(2, #gpu.glow())
    assert.equal("Discrete", gpu.best().name)
    gpu.glow()
    assert.equal(1, calls)
  end)

  it("keeps one choice per GPU and backend, even for one vendor", function()
    wezterm.gui.enumerate_gpus = function()
      return {
        {
          backend = "Vulkan",
          device = 7,
          device_type = "DiscreteGpu",
          name = "Card",
          vendor = 4098,
        },
        { backend = "Gl", device = 7, device_type = "DiscreteGpu", name = "Card", vendor = 4098 },
      }
    end
    local gpu = require "lantern.flames.gpus.gpus"
    local choices = gpu.glow()
    assert.equal(2, #choices)
    assert.are_not.equal(choices[1].id, choices[2].id)
    local cfg = {}
    gpu.ignite(cfg, { choice = { id = "4098:7:Gl" } })
    assert.equal("Gl", cfg.webgpu_preferred_adapter.backend)
    -- Saved state from older versions holds only the vendor.
    local legacy = {}
    gpu.ignite(legacy, { choice = { id = "4098" } })
    assert.equal("Vulkan", legacy.webgpu_preferred_adapter.backend)
  end)

  it("persists GPU descriptor and restores it without enumeration", function()
    local lantern = lantern_with_state()
    local cfg = {}
    lantern.wick("gpus"):select(cfg, { choice = { id = "1000:0:Dx12" } })
    local saved = lantern.state.get "gpus"
    assert.same(cfg.webgpu_preferred_adapter, saved.adapter)
    assert.equal(1, calls)

    package.loaded["lantern.flames.gpus.gpus"] = nil
    lantern.state._reset_for_tests()
    local restored = lantern.rekindle()
    assert.same(cfg.webgpu_preferred_adapter, restored.webgpu_preferred_adapter)
    assert.equal(1, calls)
  end)

  it("migrates legacy vendor-only state once", function()
    local lantern = lantern_with_state()
    lantern.state.save("gpus", {
      id = "1000",
      wick = "gpus",
      module = "lantern.flames.gpus.gpus",
    })
    local restored = lantern.rekindle()
    assert.equal("Discrete", restored.webgpu_preferred_adapter.name)
    assert.equal(1, calls)
    assert.same(restored.webgpu_preferred_adapter, lantern.state.get("gpus").adapter)

    package.loaded["lantern.flames.gpus.gpus"] = nil
    lantern.state._reset_for_tests()
    assert.same(restored.webgpu_preferred_adapter, lantern.rekindle().webgpu_preferred_adapter)
    assert.equal(1, calls)
  end)

  it("does not re-import legacy state after clear", function()
    local fh = assert(io.open(legacy_path, "w"))
    fh:write '{"fonts":{"id":"hack-nf","wick":"fonts"}}'
    fh:close()
    local lantern = lantern_with_state()
    assert.equal("hack-nf", lantern.state.all().fonts.id)

    lantern.state.clear()
    lantern.state._reset_for_tests()
    assert.is_nil(lantern.state.all().fonts)

    wezterm._reset()
    lantern.state._reset_for_tests()
    assert.is_nil(lantern.state.all().fonts)
    assert.truthy(io.open(legacy_path .. ".migrated"))
    os.remove(legacy_path .. ".migrated")
  end)

  it("logs missing legacy adapter without persisting a false descriptor", function()
    local lantern = lantern_with_state()
    lantern.state.save("gpus", {
      id = "missing",
      wick = "gpus",
      module = "lantern.flames.gpus.gpus",
    })
    assert.is_nil(lantern.rekindle().webgpu_preferred_adapter)
    assert.is_nil(lantern.state.get("gpus").adapter)
    assert.equal(1, calls)
    assert.is_true(#wezterm._logs.error > 0)
  end)
end)
