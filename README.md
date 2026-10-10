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
| `krtiiik:setup-project` | Set up Claude for a project: assemble a `CLAUDE.md` (plus optional settings and hooks) from the [modules](skills/setup-project/modules/) you pick. |

### Adding a `setup-project` module

Drop a Markdown file into `skills/setup-project/modules/`; its frontmatter `description` is what the picker shows. The format is documented in [`SKILL.md`](skills/setup-project/SKILL.md).

## Credits

- **grilling** is adapted from the
  [`grilling` skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)
  in [mattpocock/skills](https://github.com/mattpocock/skills) by Matt Pocock,
  used under the MIT License. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[MIT](LICENSE) © Krtiiik. Third-party material is listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
