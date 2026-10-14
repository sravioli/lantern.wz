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

  it("persists GPU descriptor and restores it without enumeration", function()
    local lantern = lantern_with_state()
    local cfg = {}
    lantern.wick("gpus"):select(cfg, { choice = { id = "1000" } })
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
