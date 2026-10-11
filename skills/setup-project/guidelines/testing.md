---
name: Testing
description: General testing rules: fix the code rather than the test, reproduce bugs with a failing test, ship tests with changes, follow the existing framework.
suggests: [test-commands, better-git-messages]
---

## Testing

- When a test fails, fix the code. Change a test only when it is wrong or the requested behaviour changed, and say so. Never skip, delete or loosen a test to get it passing.
- Reproduce a bug with a failing test before fixing it, and keep that test.
- Ship tests with new or changed behaviour in the same change.
- Follow the project's existing test framework, layout, naming and helpers; do not introduce another framework or assertion library.
