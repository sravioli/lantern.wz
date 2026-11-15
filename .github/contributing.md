# lantern.wz Contributing Guide

Thanks for helping improve lantern.wz. This guide covers what we accept, how to set up a checkout, and how a change gets merged.

We accept the following types of contributions:

- Source code: bug fixes, new features, and improvements to wicks, flames, persistence, formatting, or the public API. See [Environment setup](#environment-setup), [Best practices](#best-practices), and [Contribution workflow](#contribution-workflow).
- Documentation: improvements to the README, inline LuaLS annotations, or issue templates. See [Text formats](#text-formats).
- Bug reports: reproducible issues filed through the [bug report template](ISSUE_TEMPLATE/bug_report.md). See [Report issues and bugs](#report-issues-and-bugs).

We do not accept translations or social media and outreach contributions.

## Overview

lantern.wz is a [WezTerm](https://wezfurlong.org/wezterm/) plugin for configurable selection workflows. See the [README](readme.md) for usage details.

## Ground rules

Read the [Code of Conduct](code_of_conduct.md) before contributing.

## Share ideas

To propose a new idea:

1. Check existing [issues](https://github.com/sravioli/lantern.wz/issues) to avoid duplicates.
2. Open a new issue describing the idea, its motivation, and, if applicable, a rough implementation approach.
3. Wait for feedback from a maintainer before starting work.

## Before you start

You need:

- A [GitHub account](https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account)
- [Git](https://git-scm.com/)
- [WezTerm](https://wezfurlong.org/wezterm/installation.html), to test changes
- [Busted](https://lunarmodules.github.io/busted/) and [luacheck](https://github.com/lunarmodules/luacheck), installed with LuaRocks
- [StyLua](https://github.com/JohnnyMorganz/StyLua) and [Selene](https://kampfkarren.github.io/selene/)

## Environment setup

1. Fork the repository on GitHub.
2. Clone your fork:

   ```sh
   git clone https://github.com/<your-username>/lantern.wz.git
   cd lantern.wz
   ```

3. To test the plugin locally, point your WezTerm config at the checkout:

   ```lua
   local lantern = wezterm.plugin.require(
     "file:///" .. wezterm.config_dir .. "/plugins/lantern.wz"
   )
   ```

   This plugin validates its options with warden.wz. Specs load it from a sibling
   checkout, so clone `warden.wz` next to this repository:

   ```sh
   git clone https://github.com/sravioli/warden.wz ../warden.wz
   ```

4. Run the checks to confirm the setup works:

   ```sh
   busted --verbose
   luacheck plugin spec
   selene --display-style=quiet plugin
   stylua --check plugin spec
   ```

## Best practices

- Keep each commit focused on a single change.
- Run `stylua plugin spec` before committing. The project uses 2-space indentation, Unix (LF) line endings, double quotes, and omitted call parentheses where safe. See [`stylua.toml`](../stylua.toml).
- Leave `require` ordering to StyLua; `sort_requires` is enabled.
- Update or add `---@class`, `---@field`, `---@param`, and `---@return` annotations when changing public APIs. They live inline under `plugin/`.
- Add or update Busted tests in `spec/` when you change public behavior. Bug fixes need a regression test.

## Contribution workflow

### Fork and clone

See [Environment setup](#environment-setup). For a general guide to the fork-and-branch workflow, read [Using the Fork-and-Branch Git Workflow](https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/).

### Report issues and bugs

Use the [bug report template](ISSUE_TEMPLATE/bug_report.md). Include your OS, WezTerm version, lantern.wz version or commit, relevant configuration code, and steps to reproduce the bug.

### Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/) enforced by [Cocogitto](https://docs.cocogitto.io/). Every commit message must follow this format:

```text
<type>[(scope)]: <description>
```

Standard types are `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `ci`, `build`, and `revert`.

Project-specific types:

| Type      | Purpose                         | In changelog? |
| --------- | ------------------------------- | ------------- |
| `chore`   | Miscellaneous maintenance tasks | No            |
| `hotfix`  | Urgent bug fixes                | Yes           |
| `release` | Release bookkeeping             | Yes           |

Examples:

```text
fix(scope): handle nil value in lookup
feat(scope): add a new option
docs: update README usage section
chore: bump stylua config
```

### Branch creation

Create a descriptive branch from `main`, prefixed with the commit type (`fix/`, `feat/`, `docs/`):

```sh
git switch -c feat/my-new-feature main
```

### Pull requests

1. Push your branch to your fork.
2. Open a pull request against `main` on [sravioli/lantern.wz](https://github.com/sravioli/lantern.wz).
3. Describe the changes and reference any related issues.
4. Make sure the checks from [Environment setup](#environment-setup) pass.
5. A maintainer will review the PR. If you don't get feedback within a reasonable time, leave a comment to request a review.

### Releases

Releases are automated. When a maintainer bumps the version with `cog bump`, Cocogitto creates a SemVer tag and pushes it. A GitHub Actions workflow then generates a changelog and publishes a GitHub release. Contributors do not need to manage releases.

### Text formats

- Source code is written in Lua and formatted with StyLua.
- Documentation (README, issue templates, contributing guide) is written in Markdown.

## Project notes

Lantern has three core concepts: wicks (named selectable collections), flames
(modules or inline tables that expose choices with `glow()`), and ignition
(applying a selected choice with `ignite(config, ctx)`). Keep the public API
terms consistent: `lantern`, `wick`, `flame`, `glow`, `ignite`, and `rekindle`.

Lantern loads `log.wz`, `memo.wz`, `ribbon.wz`, `warp.wz`, and `warden.wz`
through `wezterm.plugin.require`, so keep those available when testing offline
or from local checkouts.

## Licensing

Code contributions are licensed under the [GNU General Public License v2](../LICENSE). Documentation contributions are licensed under [Creative Commons Attribution-NonCommercial 4.0 International](../LICENSE-DOCS).

---

> Template based on the [Contributing Guide template](https://thegooddocsproject.dev/) from The Good Docs Project.
