---@diagnostic disable: undefined-global

package.path = "spec/support/?.lua;" .. package.path
local wezterm = require "mock_wezterm"

local function reset_modules()
  for name in pairs(package.loaded) do
    if name:match "^lantern" or name:match "^custom_flames" then
      package.loaded[name] = nil
    end
  end
  wezterm._reset()
end

local function tmp_path(name)
  local base = os.getenv "TEMP" or os.getenv "TMP" or "."
  return base .. "/" .. name
end

local function remove_file(path)
  os.remove(path)
end

local function plugin_flame_path(...)
  local parts = { "C:/lantern.wz", "plugin", "lantern", "flames", ... }
  return table.concat(parts, "/")
end

local function set_builtin_flames(name, files)
  local root = plugin_flame_path(name)
  local entries = {}
  for i = 1, #files do
    entries[i] = root .. "/" .. files[i]
  end
  wezterm._set_read_dir(root, entries)
end

local function new_window(effective_config)
  local overrides = {}
  local window = {
    actions = {},
    perform_action = function(self, action)
      self.actions[#self.actions + 1] = action
    end,
    effective_config = function()
      return effective_config or {}
    end,
    get_config_overrides = function()
      return overrides
    end,
    set_config_overrides = function(_, next_overrides)
      overrides = next_overrides
    end,
  }

  return window, function()
    return overrides
  end
end

local function open_selector(action, window)
  assert.is_function(wezterm._events[action.name])
  wezterm._events[action.name](window, {})
  return assert(window.actions[1])
end

local function choice_label(selector, id)
  for i = 1, #selector.args.choices do
    local choice = selector.args.choices[i]
    if choice.id == id then
      return choice.label
    end
  end
end

local function select_choice(selector, window, id, label)
  selector.args.action.fn(window, nil, id, label or choice_label(selector, id))
end

describe("lantern usage scenarios", function()
  before_each(reset_modules)

  it("opens every built-in action with the expected event names", function()
    local lantern = require "lantern.api"

    assert.equal("lantern:light:colorschemes", lantern.light.colorscheme().name)
    assert.equal("lantern:light:fonts", lantern.light.font().name)
    assert.equal("lantern:light:font-sizes", lantern.light.font_size().name)
    assert.equal("lantern:light:font-leadings", lantern.light.font_leading().name)
    assert.equal("lantern:light:gpus", lantern.light.gpu().name)
    assert.equal("lantern:light:window-opacity", lantern.light.window_opacity().name)
    assert.equal("lantern:light:window-padding", lantern.light.window_padding().name)
    assert.equal("lantern:light:cursor-style", lantern.light.cursor_style().name)
    assert.equal("lantern:light:inactive-pane-opacity", lantern.light.inactive_pane_opacity().name)
    assert.equal("lantern:light:font-ligatures", lantern.light.font_ligatures().name)
    assert.equal("lantern:light:tab-bar-style", lantern.light.tab_bar_style().name)
  end)

  it("applies a built-in colorscheme through the selector callback", function()
    local state_path = tmp_path "lantern-colorscheme-usage.json"
    local legacy_path = tmp_path "lantern-colorscheme-legacy.json"
    remove_file(state_path)
    remove_file(legacy_path)
    set_builtin_flames("colorschemes", { "kanagawa-wave.lua" })

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { path = state_path, legacy_path = legacy_path },
      color = { opacity = 0.72 },
    }

    local window, get_overrides = new_window {
      color_scheme = "current",
      color_schemes = {
        current = { foreground = "#dcd7ba" },
      },
    }
    local selector = open_selector(lantern.light.colorscheme(), window)

    select_choice(selector, window, "kanagawa-wave")

    local overrides = get_overrides()
    assert.equal("InputSelector", selector.type)
    assert.equal("Lantern: colorscheme", selector.args.title)
    assert.equal("kanagawa-wave", overrides.color_scheme)
    assert.is_table(overrides.color_schemes["kanagawa-wave"])
    assert.equal(0.72, overrides.background[1].opacity)
    assert.equal("< + >", overrides.tab_bar_style.new_tab)
    assert.equal("kanagawa-wave", lantern.state.get("colorschemes").id)
    assert.equal(
      "lantern.flames.colorschemes.kanagawa-wave",
      lantern.state.get("colorschemes").module
    )

    remove_file(state_path)
    remove_file(legacy_path)
  end)

  it("lets users customize tab button formatting for colorscheme choices", function()
    set_builtin_flames("colorschemes", { "kanagawa-wave.lua" })

    local formatter_ctx = nil
    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { enabled = false },
      color = {
        set_tab_button = function(cfg, scheme, ctx)
          formatter_ctx = {
            name = ctx.name,
            foreground = scheme.foreground,
          }
          cfg.tab_bar_style = {
            new_tab = "custom:" .. ctx.name,
            new_tab_hover = "custom-hover:" .. ctx.name,
          }
        end,
      },
    }

    local window, get_overrides = new_window()
    local selector = open_selector(lantern.light.colorscheme(), window)
    select_choice(selector, window, "kanagawa-wave")

    local overrides = get_overrides()
    assert.equal("custom:kanagawa-wave", overrides.tab_bar_style.new_tab)
    assert.equal("custom-hover:kanagawa-wave", overrides.tab_bar_style.new_tab_hover)
    assert.equal("kanagawa-wave", formatter_ctx.name)
    assert.equal("#DCD7BA", formatter_ctx.foreground)
  end)

  it("resets fonts to configured defaults and clears persisted font state", function()
    local state_path = tmp_path "lantern-font-reset-usage.json"
    local legacy_path = tmp_path "lantern-font-reset-legacy.json"
    remove_file(state_path)
    remove_file(legacy_path)
    set_builtin_flames("fonts", { "reset.lua" })

    local lantern = require "lantern.api"
    local default_font = {
      font = wezterm.font "CommitMono",
      font_size = 13,
      line_height = 1.15,
    }
    lantern.setup {
      persistence = { path = state_path, legacy_path = legacy_path },
      default_font = default_font,
    }
    lantern.state.save("fonts", { id = "old-font", wick = "fonts" })

    local window, get_overrides = new_window()
    local selector = open_selector(lantern.light.font(), window)
    select_choice(selector, window, "reset")

    local overrides = get_overrides()
    assert.equal(default_font.font, overrides.font)
    assert.equal(13, overrides.font_size)
    assert.equal(1.15, overrides.line_height)
    assert.is_nil(lantern.state.get "fonts")

    remove_file(state_path)
    remove_file(legacy_path)
  end)

  it("applies a concrete built-in font flame through the font selector", function()
    set_builtin_flames("fonts", { "fira-code-nf.lua", "reset.lua" })

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { enabled = false },
    }

    local window, get_overrides = new_window()
    local selector = open_selector(lantern.light.font(), window)
    select_choice(selector, window, "fira-code-nf")

    local overrides = get_overrides()
    assert.equal("font_with_fallback", overrides.font.type)
    assert.equal("FiraCode Nerd Font", overrides.font.spec[1].family)
    assert.equal("font_with_fallback", overrides.font_rules[1].font.type)
    assert.equal("Monaspace Radon", overrides.font_rules[1].font.spec[1].family)
  end)

  it("changes font size and line height from built-in generated flames", function()
    set_builtin_flames("font-sizes", { "font-sizes.lua" })
    set_builtin_flames("font-leadings", { "font-leadings.lua" })

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { enabled = false },
      default_font = { font_size = 15 },
    }

    local size_window, get_size_overrides = new_window()
    local size_selector = open_selector(lantern.light.font_size(), size_window)
    select_choice(size_selector, size_window, "18", "18pt")

    local leading_window, get_leading_overrides = new_window()
    local leading_selector = open_selector(lantern.light.font_leading(), leading_window)
    select_choice(leading_selector, leading_window, "1.1", "1.1x")

    assert.equal(18, get_size_overrides().font_size)
    assert.equal(1.1, get_leading_overrides().line_height)
  end)

  it("selects a GPU adapter from the built-in GPU wick", function()
    set_builtin_flames("gpus", { "gpus.lua" })

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { enabled = false },
    }

    local window, get_overrides = new_window()
    local selector = open_selector(lantern.light.gpu(), window)
    select_choice(selector, window, "1000")

    assert.equal("Lantern: GPU", selector.args.title)
    assert.equal("Discrete", get_overrides().webgpu_preferred_adapter.name)
  end)

  it("applies built-in window appearance flames through selector callbacks", function()
    set_builtin_flames("window-opacity", { "window-opacity.lua" })
    set_builtin_flames("window-padding", { "window-padding.lua" })
    set_builtin_flames("inactive-pane-opacity", { "inactive-pane-opacity.lua" })
    set_builtin_flames("tab-bar-style", { "tab-bar-style.lua" })

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { enabled = false },
    }

    local opacity_window, get_opacity_overrides = new_window()
    local opacity_selector = open_selector(lantern.light.window_opacity(), opacity_window)
    select_choice(opacity_selector, opacity_window, "0.85")
    assert.equal("Lantern: window opacity", opacity_selector.args.title)
    assert.equal(0.85, get_opacity_overrides().window_background_opacity)

    local padding_window, get_padding_overrides = new_window()
    local padding_selector = open_selector(lantern.light.window_padding(), padding_window)
    select_choice(padding_selector, padding_window, "compact")
    assert.equal(2, get_padding_overrides().window_padding.left)
    assert.equal(0, get_padding_overrides().window_padding.top)

    local pane_window, get_pane_overrides = new_window()
    local pane_selector = open_selector(lantern.light.inactive_pane_opacity(), pane_window)
    select_choice(pane_selector, pane_window, "dim")
    assert.equal(0.85, get_pane_overrides().inactive_pane_hsb.saturation)
    assert.equal(0.75, get_pane_overrides().inactive_pane_hsb.brightness)

    local tab_window, get_tab_overrides = new_window()
    local tab_selector = open_selector(lantern.light.tab_bar_style(), tab_window)
    select_choice(tab_selector, tab_window, "powerline")
    assert.equal(false, get_tab_overrides().use_fancy_tab_bar)
    assert.equal(" <", get_tab_overrides().tab_bar_style.active_tab_left)
    assert.equal("> ", get_tab_overrides().tab_bar_style.active_tab_right)
  end)

  it("applies built-in cursor and font rendering flames", function()
    set_builtin_flames("cursor-style", { "cursor-style.lua" })
    set_builtin_flames("font-ligatures", { "font-ligatures.lua" })

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { enabled = false },
    }

    local cursor_window, get_cursor_overrides = new_window()
    local cursor_selector = open_selector(lantern.light.cursor_style(), cursor_window)
    select_choice(cursor_selector, cursor_window, "blinking-bar")
    assert.equal("BlinkingBar", get_cursor_overrides().default_cursor_style)

    local ligature_window, get_ligature_overrides = new_window()
    local ligature_selector = open_selector(lantern.light.font_ligatures(), ligature_window)
    select_choice(ligature_selector, ligature_window, "off")
    assert.same({ "calt=0", "clig=0", "liga=0" }, get_ligature_overrides().harfbuzz_features)
  end)

  it("loads user-defined flame directories from the light event", function()
    local custom_dir = "C:\\wezterm\\custom_flames"
    wezterm._set_read_dir(custom_dir, {
      custom_dir .. "\\workspace.lua",
    })
    package.loaded["custom_flames.workspace"] = {
      get = function()
        return { id = "workspace", label = "Workspace Theme" }
      end,
      pick = function(cfg, ctx)
        cfg.workspace_theme = ctx.choice.id
      end,
    }

    local lantern = require "lantern.api"
    lantern.setup {
      persistence = { enabled = false },
    }
    lantern.add_wick("workspace", {
      title = "Workspace flames",
      description = "Choose workspace theme",
      fuzzy = false,
      alphabet = "abc",
      flame_dirs = { custom_dir },
    })
    assert.is_nil(wezterm._read_dir_calls["C:/wezterm/custom_flames"])

    local window, get_overrides = new_window()
    local selector = open_selector(lantern.light "workspace", window)
    select_choice(selector, window, "workspace")

    assert.equal("Workspace flames", selector.args.title)
    assert.equal(false, selector.args.fuzzy)
    assert.equal("abc", selector.args.alphabet)
    assert.equal("search Choose workspace theme: ", selector.args.description)
    assert.equal("workspace", get_overrides().workspace_theme)
    assert.equal(1, wezterm._read_dir_calls["C:/wezterm/custom_flames"])
  end)

  it("leaves config overrides untouched when a selector is cancelled", function()
    local lantern = require "lantern.api"
    lantern.add_wick("custom", {
      persist = false,
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

    local window, get_overrides = new_window()
    local selector = open_selector(lantern.light "custom", window)
    selector.args.action.fn(window, nil, nil, nil)

    assert.is_nil(get_overrides().value)
  end)
end)
