---
name: Semantic Versioning
description: Default to semver, never bump versions unprompted, tag releases on request.
suggests: [keep-a-changelog]
decisions:
  - id: scheme
    question: Which version scheme does this project use?
    scout: Look at existing git tags (git tag --list), version fields in manifests (package.json, pyproject.toml, *.csproj, plugin.json), and version strings in docs. Match the number of components already in use; if there are no versions yet, prefer the full scheme.
    options:
      - value: MAJOR.MINOR.PATCH
        description: Full semver; fixes bump PATCH, features bump MINOR, breaking changes bump MAJOR.
      - value: MAJOR.MINOR
        description: Two-part versions for non-code projects (docs, content, notes) where "fixes" don't apply; content updates bump MINOR, major rewrites or restructures bump MAJOR.
---

## Versioning

- Use Semantic Versioning (semver.org) with {{scheme}} version numbers.
- Never bump the version on your own initiative. Only when explicitly asked for a release or version bump, bump per semver rules and tag the commit (`git tag -a v<version> -m "v<version>"`). You may mention in one line that something looks release-worthy, but don't act on it.
