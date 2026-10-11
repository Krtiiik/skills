---
name: Project Documentation
description: Docs written for Claude (glossary, architecture, conventions, a shared TODO list) that Claude reads to understand the codebase and keeps current as the project evolves.
suggests: [better-git-messages]
decisions:
  - id: docs
    multi: true
    question: Which docs should Claude have for this project?
    scout: Check which of CONTEXT.md, ARCHITECTURE.md, CONVENTIONS.md and TODO.md already exist (project root, docs/, .claude/) and say so in that option's description, since installing over them prompts for overwrite. Recommend CONTEXT and ARCHITECTURE when the project has more than a handful of source files (git ls-files); recommend CONVENTIONS when the code has established patterns; recommend TODO when the user works with Claude across many sessions. For a near-empty repo recommend none beyond TODO.
    options:
      - label: CONTEXT
        value: "- @{{location:rel}}CONTEXT.md: glossary of the project's terms and top-level concepts. Use these terms exactly in code, commits and conversation."
        description: Project language, as terms with one-line definitions and how they relate. Always loaded into context, so it stays short.
        files:
          "{{location}}CONTEXT.md": CONTEXT.md
        seed: seed/context.md
      - label: ARCHITECTURE
        value: "- `{{location:rel}}ARCHITECTURE.md`: the big picture (components, how they relate, data flow) and the reasons behind design choices. Read it before changing structure or adding a component, and when a design looks odd."
        description: Overview plus inline "why" notes for designs that need explaining. Leaves out anything the source already shows.
        files:
          "{{location}}ARCHITECTURE.md": ARCHITECTURE.md
        seed: seed/architecture.md
      - label: CONVENTIONS
        value: "- `{{location:rel}}CONVENTIONS.md`: idioms and placement rules that a linter or formatter can't enforce. Read it before writing new code."
        description: Error handling style, naming, where new code goes, test patterns; whatever a newcomer would get wrong.
        files:
          "{{location}}CONVENTIONS.md": CONVENTIONS.md
        seed: seed/conventions.md
      - label: TODO
        value: |-
          - `{{location:rel}}TODO.md`: task list shared between the user and you, with `## Inbox` (written by the user) and `## Suggested` (proposed by you) sections and items as `- [ ] task: why or context`.
            - Work on items only when the user asks ("work on the TODO", "do item 3"); never start them unprompted.
            - When asked to find bugs, suggest features or leave a handoff, add the findings under `## Suggested` for the user to triage. Don't add items unprompted.
            - Tick an item (`- [x]`) in the same change that completes it.
        description: Two-way task list. The user writes todos and tells Claude to work on them, or asks Claude to hunt for bugs and feature ideas and file them for later.
        files:
          "{{location}}TODO.md": TODO.md
  - id: location
    type: path
    question: Where should the doc files live?
    scout: Look for an existing docs/ folder. The instruction file is already chosen, so the first option follows it; recommend it unless docs/ exists and holds human-facing documentation, in which case recommend keeping Claude's files out of it.
    options:
      - label: Beside the instruction file
        value: "{{claude_dir}}"
        description: Same folder as the CLAUDE file you chose (the project root for ./CLAUDE.md or CLAUDE.local.md, .claude/ for ./.claude/CLAUDE.md). Keeps Claude's files together.
      - label: docs/
        value: docs/
        description: Conventional and visible to humans too, but may mix with human-facing docs.
      - label: Project root
        value: ""
        description: Files next to the code; clutters the root as docs grow.
  - id: seed
    question: Should a first draft of the docs be written from the existing codebase?
    scout: Count tracked source files (git ls-files). For an empty or near-empty repo recommend templates only; otherwise recommend the draft.
    options:
      - label: Draft from codebase
        value: drafted from the codebase
        run_seeds: true
        description: One sub-agent per chosen doc (TODO excepted) scouts the repo and fills the template in parallel. Unsure items are marked unconfirmed; review with git diff.
      - label: Templates only
        value: templates only
        description: Empty templates with guidance comments; content grows as Claude works.
---

## Project documentation

Docs for Claude, kept in the repository:

{{docs}}

Maintaining them:

- Record only what the source can't tell you: intent, vocabulary, rationale and non-obvious relationships. Don't list files, signatures or anything a quick search would find.
- Update a doc in the same change that makes it stale or introduces something worth recording (a new term, a design choice and its reason, a convention). Don't wait to be asked and don't batch it for later.
- Keep entries short. When a doc and the code disagree, trust the code and fix the doc.
