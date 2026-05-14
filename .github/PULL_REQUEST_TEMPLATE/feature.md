### Summary

Describe the new lantern.wz feature and the user-facing selector workflow it
enables.

### Motivation

Explain why this belongs in lantern.wz. Focus on wicks, flames, selectors,
persistence, state loading, WezTerm config application, or command-palette
integration.

### API Sketch

```lua
-- show intended wick, flame, setup, picker, or rekindle usage
```

### Behavior

Describe how the feature behaves, including default options, state persistence,
selected config fields, picker entries, fallback behavior, and failure cases.

### Compatibility

- [ ] Non-breaking
- [ ] Potentially breaking
- [ ] Breaking

If this is potentially breaking or breaking, explain the migration path.

### Tests

Describe the tests added or updated for this behavior.

### Documentation

Describe the README, examples, annotation, or template changes made for this
feature.

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

