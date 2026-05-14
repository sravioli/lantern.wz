---
name: Bug report
about: Report a reproducible problem
title: "[BUG]"
labels: bug
assignees: sravioli
---

# Bug Report

> Fill out the sections below. Sections marked _(optional)_ can be left blank
> when they do not apply.
>
> Before submitting, check existing issues to make sure this bug hasn't already
> been reported.

## Summary (optional)

A short description of the bug. If the issue title already covers it, you can
skip this section.

## Environment

- **OS**: (e.g. Windows 11, macOS 15.4, Ubuntu 24.04)
- **WezTerm version**: (e.g. `20240203-110809-5046fc22`)
- **lantern.wz version/commit**: (e.g. `v1.0.0` or commit hash)
- **Installation method**: git (`wezterm.plugin.require`) / local checkout
- **Lua version** (if known):

## Setup

Provide your Lantern configuration and usage code so the issue can be
reproduced.

```lua
-- Example:
-- local lantern = wezterm.plugin.require "https://github.com/sravioli/lantern.wz"
-- config.keys = {
--   { key = "c", mods = "CTRL|SHIFT", action = lantern.light.colorscheme() },
-- }
```

## Steps to reproduce

1. Step 1
2. Step 2
3. Step 3

## Observed behavior

Describe what actually happened. Avoid assumptions about the cause.

## Expected behavior (optional)

Describe what you expected to happen instead.

## Proof (optional)

Attach relevant output: WezTerm debug overlay messages, stack traces, or
screenshots.

```text
-- paste logs or output here
```

## Configuration snippet (optional)

If the bug only appears with a specific WezTerm configuration, include the
relevant portion of your `wezterm.lua`.

```lua
-- paste config here
```

## Additional context (optional)

Add anything else that might help, such as other active plugins, unusual
environment variables, or processes that may affect performance.

---

> Template based on the [Bug Report template](https://thegooddocsproject.dev/)
> from The Good Docs Project.
