---@diagnostic disable: undefined-global

package.path = "spec/support/?.lua;" .. package.path
require "mock_wezterm"

-- Checked first: loading lantern must not read its mosaic integration.
require "lantern.api"
local read_by_lantern = package.loaded["lantern.mosaic.scheme"] ~= nil

describe("mosaic integration lantern.scheme", function()
  local descriptor
  local mosaic = {
    palette = {
      accent = function(i)
        return function()
          return { fg = "accent" .. i }
        end
      end,
    },
  }

  local function window(overrides)
    return {
      get_config_overrides = function()
        return overrides
      end,
    }
  end

  before_each(function()
    descriptor = require "lantern.mosaic.scheme"
  end)

  it("is not read when lantern loads", function()
    assert.is_false(read_by_lantern)
  end)

  it("follows the descriptor contract", function()
    assert.equal(1, descriptor.api)
    assert.is_function(descriptor.new)
    assert.is_function(descriptor.new({}, mosaic))
  end)

  it("shows the configured scheme", function()
    local spec = descriptor.new({}, mosaic)(window(nil), nil, nil, { color_scheme = "Kanagawa" })
    assert.is_true(spec.enabled)
    assert.equal("Kanagawa", spec.text.value)
    assert.equals(6, spec.accent)
    assert.is_nil(spec.style) -- content only: the preset decorates it
    assert.equal("Kanagawa", spec.update())
  end)

  it("prefers the window override", function()
    local spec = descriptor.new({}, mosaic)(
      window { color_scheme = "Dawn" },
      nil,
      nil,
      { color_scheme = "Kanagawa" }
    )
    assert.equal("Dawn", spec.text.value)
  end)

  it("hides without a scheme and honours icon = false", function()
    assert.is_false(descriptor.new({}, mosaic)(window(nil), nil, nil, {}).enabled)
    local spec =
      descriptor.new({ icon = false }, mosaic)(window(nil), nil, nil, { color_scheme = "X" })
    assert.is_false(spec.icon.enabled)
  end)
end)
