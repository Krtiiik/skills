---
name: bump-version
description: Cut a release - suggest a semver bump from the changelog, ask the user to confirm it, update the changelog and version files, commit, tag, then offer to push. Use when the user asks to bump the version, cut a release, or tag a release.
---

Release the project's `[Unreleased]` changelog entries as a new version. The user's request to bump is the authorization to bump; nothing else in this skill is.

## 1. Check the starting point

- Find the changelog (`CHANGELOG.md`, `docs/CHANGELOG.md`, ...). If there is none, stop and tell the user.
- Read its `## [Unreleased]` section. If it has no entries, stop: there is nothing to release.
- Check `git status`. Uncommitted changes would end up outside the release commit, so ask the user to commit or set them aside first.

## 2. Find the current version

Collect every place the version is recorded and compare:

- latest git tag (`git tag --sort=-v:refname`) and whether it has a `v` prefix
- latest `## [x.y.z]` heading in the changelog
- version fields in manifests (`plugin.json`, `package.json`, `pyproject.toml`, `Cargo.toml`, `*.csproj`, ...); grep for the current version string to catch any others

Note how many components the project uses (`MAJOR.MINOR.PATCH` or `MAJOR.MINOR`) and keep to it.

If these disagree, say which differ and ask which is right before continuing. A common case: the manifest and changelog already name a version that was never tagged. Then offer to tag that commit instead of bumping again.

## 3. Suggest and ask for the bump

Suggest a level from the `[Unreleased]` section:

| Changelog evidence | Suggestion |
| --- | --- |
| `Removed`, or a `Changed` entry that breaks existing usage | **major** (while the version is `0.x`: **minor**, since anything may change) |
| `Added`, or a `Changed` entry that is a new behaviour | **minor** |
| Only `Fixed`, `Security`, `Deprecated`, or non-breaking `Changed` | **patch** |

Use **AskUserQuestion** with options major, minor, patch (patch is absent for two-component versions). Put the suggestion first, end its label with "(Recommended)", and in each option's description show the resulting version and the one-line reason from the changelog. Let the user override in free text, e.g. an explicit version.

## 4. Apply

1. In the changelog, move the `[Unreleased]` entries under a new `## [<version>] - <today, YYYY-MM-DD>` heading and leave an empty `## [Unreleased]` above it. If the file ends with compare links (`[Unreleased]: ...compare/...`), update them too.
2. Set the new version in every manifest found in step 2. Touch nothing else.
3. Commit the changelog and manifests together as the release commit. Follow the project's commit conventions (e.g. `chore: bump version to <version>`); if there are none, use `chore: release v<version>`.
4. Tag that commit, annotated, matching the existing tag style: `git tag -a v<version> -m "v<version>"`.

## 5. Offer to push

Do not push on your own. Show the user what was created (new version, commit hash, tag), then ask whether to push the branch and the tag together. These are two separate pushes, since a plain `git push` does not send tags:

```bash
git push
git push origin v<version>
```

If the user agrees, run both. A git guardrail may ask for confirmation first; that is expected. If the user declines, leave the commit and tag local and say so.
