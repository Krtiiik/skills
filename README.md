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
| `krtiiik:grilling` | Grill the user about a plan, decision, or idea in clickable question rounds, then confirm the shared understanding through plan-review approval. |
| `krtiiik:setup-project` | Set up Claude for a project: assemble a `CLAUDE.md` (plus optional settings and hooks) from the [guidelines](./skills/setup-project/guidelines/) (how Claude should work) and [technicalities](./skills/setup-project/technicalities/) (project-specific commands and enforcement) you pick. |

### Adding a `setup-project` guideline or technicality

Drop a Markdown file into `skills/setup-project/guidelines/` (general rules for how Claude approaches work) or `skills/setup-project/technicalities/` (the project's specific tooling and commands); its frontmatter `description` is what the picker shows. The format is documented in [`SKILL.md`](skills/setup-project/SKILL.md).

## Credits

- **grilling** is adapted from the
  [`grilling` skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)
  in [mattpocock/skills](https://github.com/mattpocock/skills) by Matt Pocock,
  used under the MIT License. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[MIT](LICENSE) © Krtiiik. Third-party material is listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
