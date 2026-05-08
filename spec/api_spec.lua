---@diagnostic disable: undefined-global

package.path = "spec/support/?.lua;" .. package.path
local wezterm = require "mock_wezterm"

local function reset_modules()
  for name in pairs(package.loaded) do
    if name:match "^lantern" then
      package.loaded[name] = nil
    end
  end
  wezterm._reset()
end

local function tmp_path(name)
  local base = os.getenv "TEMP" or os.getenv "TMP" or "."
  return base .. package.config:sub(1, 1) .. name
end

local function remove_file(path)
  os.remove(path)
end

describe("lantern api", function()
  before_each(reset_modules)

  it("exposes named light actions", function()
    local lantern = require "lantern.api"

    local action = lantern.light.colorscheme()

    assert.equal("EmitEvent", action.type)
    assert.equal("lantern:light:colorschemes", action.name)
  end)

  it("supports callable light lookup for custom wicks", function()
    local lantern = require "lantern.api"
    lantern.add_wick("custom", {
      flames = {
        {
          glow = function()
            return { id = "one", label = "One" }
          end,
          ignite = function(cfg)
            cfg.value = "one"
          end,
        },
      },
    })

    local action = lantern.light "custom"

    assert.equal("EmitEvent", action.type)
    assert.equal("lantern:light:custom", action.name)
  end)

  it("opens an InputSelector and applies the selected flame", function()
    local lantern = require "lantern.api"
    lantern.add_wick("custom", {
      persist = false,
      flames = {
        {
          glow = function()
            return {
              { id = "b", label = "Bee" },
              { id = "a", label = "Aye" },
            }
          end,
          ignite = function(cfg, ctx)
            cfg.value = ctx.choice.id
          end,
        },
      },
    })

    local action = lantern.light "custom"
    local overrides = {}
    local window = {
      actions = {},
      perform_action = function(self, act)
        self.actions[#self.actions + 1] = act
      end,
      get_config_overrides = function()
        return overrides
      end,
      set_config_overrides = function(_, next_overrides)
        overrides = next_overrides
      end,
    }

    wezterm._events[action.name](window, {})
    local selector = window.actions[1]
    selector.args.action.fn(window, nil, "a", "Aye")

    assert.equal("InputSelector", selector.type)
    assert.equal("a", selector.args.choices[1].id)
    assert.equal("b", selector.args.choices[2].id)
    assert.equal("a", overrides.value)
  end)

  it("keeps reset choices first", function()
    local lantern = require "lantern.api"
    local wick = lantern.add_wick("custom", {
      flames = {
        {
          glow = function()
            return {
              { id = "z", label = "Zulu" },
              { id = "reset", label = "Reset" },
            }
          end,
          ignite = function() end,
        },
      },
    })

    wick:_initialize()
    local choices = wick.format_choices(wick._choices, {})
    table.sort(choices, wick.comp)

    assert.equal("reset", choices[1].id)
  end)

  it("persists and rekindles selections", function()
    local state_path = tmp_path "lantern-state-test.json"
    local legacy_path = tmp_path "lantern-legacy-empty.json"
    remove_file(state_path)
    remove_file(legacy_path)

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { path = state_path, legacy_path = legacy_path },
    }
    lantern.add_wick("custom", {
      flames = {
        {
          module_path = "lantern.test_flame",
          glow = function()
            return { id = "hot", label = "Hot" }
          end,
          ignite = function(cfg)
            cfg.value = "hot"
          end,
        },
      },
    })

    package.loaded["lantern.test_flame"] = {
      ignite = function(cfg)
        cfg.value = "hot"
      end,
    }

    local wick = lantern.wick "custom"
    wick:select({}, { choice = { id = "hot", label = "Hot" } })

    package.loaded["lantern.state"]._reset_for_tests()
    local restored = lantern.rekindle()

    assert.equal("hot", restored.value)
    remove_file(state_path)
    remove_file(legacy_path)
  end)

  it("migrates legacy picker module paths", function()
    local state_path = tmp_path "lantern-state-migrated.json"
    local legacy_path = tmp_path "picker-state-legacy.json"
    remove_file(state_path)
    remove_file(legacy_path)

    local fh = assert(io.open(legacy_path, "w"))
    fh:write '{"fonts":{"id":"reset","module":"picker.assets.fonts.reset","wick":"fonts"}}'
    fh:close()

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = {
        path = state_path,
        legacy_path = legacy_path,
      },
      default_font = {
        font_size = 14,
      },
    }

    local entry = lantern.state.get "fonts"

    assert.equal("lantern.flames.fonts.reset", entry.module)
    remove_file(state_path)
    remove_file(legacy_path)
  end)

  it("ships default colorscheme and font assets", function()
    local lantern = require "lantern.api"
    local colors = lantern.wick "colorschemes"
    local fonts = lantern.wick "fonts"

    colors:_initialize()
    fonts:_initialize()

    assert.is_true(colors._choices["kanagawa-wave"] ~= nil)
    assert.is_true(fonts._choices["fira-code-nf"] ~= nil)
  end)

  it("selects the preferred GPU", function()
    local lantern = require "lantern.api"
    local gpu = lantern.gpu().pick_best()

    assert.equal("Discrete", gpu.name)
  end)
end)
