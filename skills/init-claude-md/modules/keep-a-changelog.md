---
name: Keep a Changelog
description: Maintain a CHANGELOG.md in Keep a Changelog format, updated with every user-facing change.
suggests: [semver]
decisions:
  - id: path
    question: Where should the changelog live?
    scout: Look for an existing changelog (CHANGELOG.md, CHANGELOG, HISTORY.md, docs/CHANGELOG.md, RELEASES.md) and recommend its path. If none exists, recommend CHANGELOG.md in the project root.
    options:
      - value: CHANGELOG.md
        description: The conventional location in the project root.
      - value: docs/CHANGELOG.md
        description: Keeps the root tidy when the project already has a docs folder.
---

## Changelog

- Maintain `{{path}}` in the Keep a Changelog format (keepachangelog.com).
- Log every user-facing change (feature, fix, behavior change) under an `## [Unreleased]` section at the top, added in the same commit as the change itself, not batched later.
- Only when explicitly asked for a release, move `[Unreleased]` under a new `## [<version>] - YYYY-MM-DD` heading.
