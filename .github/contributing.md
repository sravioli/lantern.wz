# Contributing to lantern.wz

Thank you for helping to improve lantern.wz. This guide tells you which
contributions we accept, how to set up a checkout, and how we merge a change.

We accept these contributions:

- Source code: bug fixes, new features, and improvements to wicks, flames, persistence, formatting, or the public API. Read
  [Environment setup](#environment-setup), [Best practices](#best-practices),
  and [Contribution workflow](#contribution-workflow).
- Documentation: improvements to the README, the inline LuaLS annotations, or
  the issue forms. Read [Text formats](#text-formats).
- Bug reports: bugs that you can reproduce, reported with the
  [bug report form](https://github.com/sravioli/lantern.wz/issues/new?template=bug_report.yml).
  Read [Report a bug](#report-a-bug).

We do not accept translations, social media posts, or outreach work.

## Overview

lantern.wz is a [WezTerm](https://wezterm.org/) plugin that lets you pick a
choice from a list and apply it to your configuration.

The [README](readme.md) tells you how to use the plugin.

## Ground rules

Read the [code of conduct](code_of_conduct.md) before you contribute.

Report security vulnerabilities in private, as the
[security policy](SECURITY.md) tells you. Do not report them in a public issue.

## Share ideas

To suggest a new idea:

1. Search the [issues](https://github.com/sravioli/lantern.wz/issues) to make
   sure that nobody suggested it before.
2. Open a
   [feature request](https://github.com/sravioli/lantern.wz/issues/new?template=feature_request.yml).
   Describe the idea and why you need it. If you can, describe how you would
   build it.
3. Wait for feedback from the maintainer before you start work.

## Before you start

You need:

- A [GitHub account](https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account)
- [Git](https://git-scm.com/)
- [WezTerm](https://wezterm.org/installation.html), to test changes
- [Busted](https://lunarmodules.github.io/busted/) and
  [luacheck](https://github.com/lunarmodules/luacheck), installed with LuaRocks
- [StyLua](https://github.com/JohnnyMorganz/StyLua) and
  [Selene](https://kampfkarren.github.io/selene/)

## Environment setup

1. Fork the repository on GitHub.
2. Clone your fork:

   ```sh
   git clone https://github.com/<your-username>/lantern.wz.git
   cd lantern.wz
   ```

3. To test the plugin locally, load the checkout in your WezTerm config:

   ```lua
   local root = wezterm.home_dir .. "/path/to/lantern.wz/plugin/"
   package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path
   local lantern = require "lantern.api"
   ```

   Specs load warden.wz from a sibling checkout,
   so clone it next to this repository:

   ```sh
   git clone https://github.com/sravioli/warden.wz ../warden.wz
   ```

4. Run the checks to make sure that the setup works:

   ```sh
   busted --verbose
   luacheck .
   selene --display-style=quiet plugin
   stylua --check .
   ```

   CI also checks the text files and the commit messages:

   ```sh
   npx prettier --check "**/*.{md,json,jsonc,yml,yaml}"
   npx markdownlint-cli2 "**/*.md"
   yamllint --strict .
   cog check main..HEAD
   ```

## Best practices

- Put one change in each commit.
- Run `stylua .` before you commit. [`stylua.toml`](../stylua.toml) sets the
  style: 2-space indentation, Unix (LF) line endings, double quotes, and no
  call parentheses where Lua permits it.
- Do not sort `require` calls by hand. StyLua sorts them.
- When you change a public API, add or update its `---@class`, `---@field`,
  `---@param`, and `---@return` annotations. The annotations are inline, in the
  files under `plugin/`.
- When you change public behavior, add or update the Busted tests in `spec/`.
  Each bug fix needs a regression test.

## Contribution workflow

### Fork and clone

Follow [Environment setup](#environment-setup). For a general guide to this
workflow, read
[Using the Fork-and-Branch Git Workflow](https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/).

### Report a bug

Use the
[bug report form](https://github.com/sravioli/lantern.wz/issues/new?template=bug_report.yml).
The form asks for your WezTerm version, your lantern.wz version or commit, a
minimal configuration, and the steps that reproduce the bug.

To reproduce the bug, copy [`minit.lua`](../minit.lua) from the repository root,
add your configuration below its marker comment, and run it without your own
config:

```sh
wezterm --config-file minit.lua
```

Paste the edited file into the form.

### Commit messages

Each commit message must follow
[Conventional Commits](https://www.conventionalcommits.org/).
[Cocogitto](https://docs.cocogitto.io/) checks every message in CI. Use this
format:

```text
<type>[(scope)]: <description>
```

The standard types are `feat`, `fix`, `docs`, `style`, `refactor`, `perf`,
`test`, `ci`, `build`, and `revert`.

This project adds three types:

| Type      | Purpose                       | In changelog? |
| --------- | ----------------------------- | ------------- |
| `chore`   | Maintenance tasks of any kind | No            |
| `hotfix`  | Urgent bug fixes              | Yes           |
| `release` | Release records               | Yes           |

Examples:

```text
fix(scope): handle nil value in lookup
feat(scope): add a new option
docs: update README usage section
chore: bump stylua config
```

### Signed commits

The `main` branch accepts only signed commits. Sign each commit with a GPG,
SSH, or S/MIME key, and add the key to your GitHub account. For the steps, see
[Signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits).

To sign all commits in this repository with an SSH key:

```sh
git config gpg.format ssh
git config user.signingkey ~/.ssh/id_ed25519.pub
git config commit.gpgsign true
```

### Branches

Create a branch from `main`. Give it a name that describes the change, and start
the name with the commit type (`fix/`, `feat/`, `docs/`):

```sh
git switch -c feat/my-new-feature main
```

### Pull requests

1. Push your branch to your fork.
2. Open a pull request against `main` on
   [sravioli/lantern.wz](https://github.com/sravioli/lantern.wz). The pull
   request template asks for a summary, the type of change, and a checklist.
3. Link related issues (`Fixes #123`).
4. Make sure that the checks from [Environment setup](#environment-setup) pass.
5. The maintainer reviews the pull request. If you get no feedback after a
   reasonable time, add a comment to ask for a review.

### Releases

Releases are automatic. The maintainer runs `cog bump`, and Cocogitto creates
and pushes a SemVer tag. A GitHub Actions workflow then writes the changelog and
publishes a GitHub release. Contributors do not manage releases.

### Text formats

- Source code: Lua, formatted with StyLua.
- Documentation (README, contributing guide): Markdown.
- Issue forms: YAML.

## Project notes

Lantern has three core terms:

- A wick is a named collection that you can select from.
- A flame is a module or inline table that lists its choices with `glow()`.
- Ignition applies the selected choice with `ignite(config, ctx)`.

Use the public API terms the same way every time: `lantern`, `wick`, `flame`,
`glow`, `ignite`, and `rekindle`.

Lantern loads `log.wz`, `memo.wz`, `ribbon.wz`, `warp.wz`, and `warden.wz` with
`wezterm.plugin.require`. When you test offline or from local checkouts, keep
these plugins available.

## Licensing

The [GNU General Public License v2](../LICENSE) covers code contributions.
[Creative Commons Attribution-NonCommercial 4.0 International](../LICENSE-DOCS)
covers documentation contributions.

We based this guide on the
[Contributing Guide template](https://thegooddocsproject.dev/) from The Good
Docs Project.
