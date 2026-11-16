#!/usr/bin/env bash
# Screenshot every lantern selector, dark (kanagawa-wave) and light
# (kanagawa-lotus) from the kanagawa plugin
# (https://github.com/kanagawa-community/wezterm): .github/assets/<scene>/{dark,light}.png.
#
# Needs KDE Plasma (spectacle) and wezterm; oxipng is used when installed.
# Run it from a session you leave alone: each shot opens a window that must
# keep the focus until it is captured.
#
#   scripts/screenshots.sh                  # every scene
#   scripts/screenshots.sh colorscheme font  # only these
#
# Scenes: colorscheme font font_size font_leading gpu window_opacity window_padding cursor_style inactive_pane_opacity font_ligatures tab_bar_style
#
# Settings (environment): LANTERN_FONT ("FiraCode Nerd Font"), LANTERN_FONT_SIZE (14),
# LANTERN_COLS (100), LANTERN_ROWS (30), LANTERN_DELAY (seconds to wait for the window, default 5).
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
delay=${LANTERN_DELAY:-5}
all=(colorscheme font font_size font_leading gpu window_opacity window_padding cursor_style inactive_pane_opacity font_ligatures tab_bar_style)
scenes=("${@:-${all[@]}}")

for tool in wezterm spectacle; do
  command -v "$tool" >/dev/null || { echo "missing: $tool" >&2; exit 1; }
done

export LANTERN_REPO="$repo"

shoot() { # scene kanagawa-scheme file-name
  local dir="$repo/.github/assets/$1"
  mkdir -p "$dir"
  LANTERN_SCENE=$1 LANTERN_KANAGAWA=$2 \
    wezterm --config-file "$repo/scripts/screenshot.wezterm.lua" start --always-new-process &
  local pid=$!
  sleep "$delay"
  spectacle --activewindow --background --nonotify --output "$dir/$3.png"
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  command -v oxipng >/dev/null && oxipng -q -o4 --strip all "$dir/$3.png"
  echo "$dir/$3.png"
}

for scene in "${scenes[@]}"; do
  shoot "$scene" wave dark
  shoot "$scene" lotus light
done
