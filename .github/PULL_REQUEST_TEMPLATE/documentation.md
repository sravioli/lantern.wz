### Summary

Describe the lantern.wz documentation change.

### Documentation Changed

List the README, examples, contributing guide, issue templates, pull request
templates, or annotation docs changed by this pull request.

### Reader Impact

Explain who benefits from this documentation change:

- Users selecting built-in wicks and flames.
- Users creating custom wicks or flames.
- Contributors changing persistence or selector behavior.

### Examples Touched

```lua
-- setup, wick, flame, picker, or rekindle example changed by this pull request
```

### Behavior Change

- [ ] Documentation only
- [ ] Documents an existing behavior
- [ ] Documents a new behavior

If this documents a new behavior, link to the implementation pull request or
commit.

### Checklist

- [ ] The change is scoped to lantern.wz.
- [ ] Public API changes are documented, if applicable.
- [ ] Wick, flame, selector, or persistence behavior is covered by tests, if applicable.
- [ ] Existing saved Lantern state remains compatible.
- [ ] Required checks pass:
  - [ ] `busted --verbose`
  - [ ] `luacheck .`
  - [ ] `stylua --check .`
  - [ ] `selene --display-style=quiet .`

