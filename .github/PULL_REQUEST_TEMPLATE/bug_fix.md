### Summary

Describe the bug fixed in lantern.wz and the user-visible selector, state, or
config behavior that changed.

### Reproduction

Provide the smallest setup that reproduced the issue.

```lua
-- setup, wick, flame, or rekindle usage that reproduced the bug
```

### Root Cause

Explain why wick registration, flame discovery, state persistence, rekindle,
picker formatting, dependency loading, or config application was wrong.

### Fix

Describe the implementation change and why it fixes the problem.

### Regression Test

Describe the regression test added or updated.

### Compatibility Impact

- [ ] Non-breaking
- [ ] Potentially breaking
- [ ] Breaking

If this changes behavior intentionally, explain why the new behavior is correct.

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

