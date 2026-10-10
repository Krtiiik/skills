# krtiiik-skills

Personal collection of [Claude Code](https://claude.com/claude-code) skills.

## Install

```
/plugin marketplace add Krtiiik/skills
/plugin install krtiiik@krtiiik-skills
```

## Skills

| Skill | Description |
| --- | --- |
| `krtiiik:grilling` | Grill the user relentlessly about a plan, decision, or idea until a shared understanding is reached. |
| `krtiiik:setup-project` | Set up Claude for a project: assemble a `CLAUDE.md` (plus optional settings and hooks) from modules you pick (Semantic Versioning, Keep a Changelog, ...). |

### `setup-project` modules

| Module | Description |
| --- | --- |
| Semantic Versioning | Default to semver, never bump versions unprompted, tag releases on request. |
| Keep a Changelog | Maintain a `CHANGELOG.md` in Keep a Changelog format, updated with every user-facing change. |
| Better Git Messages | Consistent commit messages, sensible commit cadence, and commit bodies that explain why. |
| Git Guardrails | Choose which dangerous git operations (push, history rewrites, discarding work, remote/config changes, submodules and worktrees, ...) need your confirmation, enforced via permission rules or a hook. Explains in `CLAUDE.md` that they exist and must not be avoided. |
| Filesystem Guardrails | Choose which dangerous filesystem operations (deleting, overwriting, permission changes, disk-level commands, targets outside the project) need your confirmation, enforced via permission rules or a hook. The hook exempts temp and build-output deletes. Explains in `CLAUDE.md` that they exist and must not be avoided. |
| Project Documentation | Docs written for Claude (`CONTEXT.md` glossary, `ARCHITECTURE.md`, `CONVENTIONS.md`, a shared `TODO.md`), loaded and kept current by Claude. Optionally drafted from your codebase by parallel sub-agents. |

### Adding a `setup-project` module

Drop a Markdown file into `skills/setup-project/modules/`. Its frontmatter holds `name`, `description`, optional `suggests` and optional `decisions` (each with `id`, `question`, `scout` hint, and `options`); the body is the text inserted into `CLAUDE.md`, with `{{id}}` placeholders filled from the decisions. An option can also carry `settings` (merged into the project's settings file), `files` (copied from a `modules/<id>/` folder), and a `when` condition tying them to another decision's choice. Decisions can be `multi` (pick several) or `type: path` (a folder, with `{{id:rel}}` relative to the `CLAUDE.md`), and an option can carry a `seed` prompt that a sub-agent uses to draft an installed file. See `SKILL.md` there for the full format.

## Credits

- **grilling** is adapted from the
  [`grilling` skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)
  in [mattpocock/skills](https://github.com/mattpocock/skills) by Matt Pocock,
  used under the MIT License. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[MIT](LICENSE) © Krtiiik. Third-party material is listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
