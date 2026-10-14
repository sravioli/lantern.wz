---@diagnostic disable: undefined-global

describe("plugin bootstrap snapshot", function()
  local saved_wezterm, saved_api, saved_path
  local plugin, api, calls
  local entry = {
    url = "https://github.com/sravioli/lantern.wz",
    plugin_dir = "C:\\lantern.wz",
    component = "remote_lantern",
  }

  before_each(function()
    saved_wezterm = package.loaded.wezterm
    saved_api = package.loaded["lantern.api"]
    saved_path = package.path
    calls = 0
    api = {}
    plugin = {
      list = function()
        calls = calls + 1
        return { entry }
      end,
    }
    package.loaded.wezterm = { plugin = plugin, GLOBAL = {} }
    package.loaded["lantern.api"] = api
  end)

  -- selene: allow(undefined_variable)
  after_each(function()
    package.loaded.wezterm = saved_wezterm
    package.loaded["lantern.api"] = saved_api
    package.path = saved_path
  end)

  it("shares snapshot between bootstraps without replacing native list", function()
    local native_list = plugin.list
    assert.equal(api, dofile "plugin/init.lua")
    assert.equal(api, dofile "plugin/init.lua")
    assert.equal(1, calls)
    assert.equal(native_list, plugin.list)
    assert.same({ entry }, plugin._bootstrap_plugins)
  end)

  it("reuses snapshot populated by another plugin", function()
    plugin._bootstrap_plugins = { entry }
    dofile "plugin/init.lua"
    assert.equal(0, calls)
    assert.equal(entry.plugin_dir, package.loaded.wezterm.GLOBAL.__lantern_plugin_dir)
  end)

  it("refreshes stale snapshot after a newly installed plugin appears", function()
    plugin._bootstrap_plugins = {}
    dofile "plugin/init.lua"
    assert.equal(1, calls)
    assert.same({ entry }, plugin._bootstrap_plugins)
  end)

  it("matches exact require component when local and remote clones coexist", function()
    local local_entry = {
      url = "file:///C:/plugins/lantern.wz",
      component = "local_lantern",
      plugin_dir = "C:\\local_lantern.wz",
    }
    plugin._bootstrap_plugins = { entry }
    plugin.list = function()
      calls = calls + 1
      return { entry, local_entry }
    end
    assert.equal(api, assert(loadfile "plugin/init.lua") "local_lantern")
    assert.equal(1, calls)
    assert.equal(local_entry.plugin_dir, package.loaded.wezterm.GLOBAL.__lantern_plugin_dir)
  end)

  it("fails explicitly if plugin is still absent after refresh", function()
    plugin._bootstrap_plugins = {}
    plugin.list = function()
      calls = calls + 1
      return {}
    end
    assert.has_error(function()
      dofile "plugin/init.lua"
    end, "Installed plugin not found: lantern.wz")
    assert.equal(1, calls)
  end)

  it("gets fresh snapshot in a new Lua-local WezTerm module", function()
    dofile "plugin/init.lua"
    package.loaded.wezterm = { plugin = { list = plugin.list }, GLOBAL = {} }
    dofile "plugin/init.lua"
    assert.equal(2, calls)
  end)
end)
