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
| `krtiiik:init-claude-md` | Initialize Claude for a project: assemble a `CLAUDE.md` from modules you pick (Semantic Versioning, Keep a Changelog, ...). |

### `init-claude-md` modules

| Module | Description |
| --- | --- |
| Semantic Versioning | Default to semver, never bump versions unprompted, tag releases on request. |
| Keep a Changelog | Maintain a `CHANGELOG.md` in Keep a Changelog format, updated with every user-facing change. |
| Better Git Messages | Consistent commit messages, sensible commit cadence, and confirmation before risky git operations (optionally enforced via permission rules or a hook). |

### Adding an `init-claude-md` module

Drop a Markdown file into `skills/init-claude-md/modules/`. Its frontmatter holds `name`, `description`, optional `suggests` and optional `decisions` (each with `id`, `question`, `scout` hint, and `options`); the body is the text inserted into `CLAUDE.md`, with `{{id}}` placeholders filled from the decisions. An option can also carry `settings` (merged into the project's settings file) and `files` (copied from a `modules/<id>/` folder). See `SKILL.md` there for the full format.

## Credits

- **grilling** is adapted from the
  [`grilling` skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)
  in [mattpocock/skills](https://github.com/mattpocock/skills) by Matt Pocock,
  used under the MIT License. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[MIT](LICENSE) © Krtiiik. Third-party material is listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
