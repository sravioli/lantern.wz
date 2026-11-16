-- Shared luacheck configuration, synced from community/templates.
-- WezTerm embeds Lua 5.4.
std = "lua54"

exclude_files = {
  "spec/**",
  ".luarocks/**",
}
