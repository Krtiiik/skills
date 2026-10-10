---
name: Better Git Messages
description: Consistent commit messages, sensible commit cadence, and commit bodies that explain why.
suggests: [semver, keep-a-changelog, git-guardrails]
decisions:
  - id: convention
    question: Which commit message convention does this project use?
    scout: Read recent history (git log --oneline -30). If most subjects start with a type prefix such as feat:, fix:, docs:, recommend Conventional Commits; if they are plain imperative sentences, recommend the plain option; with no history, prefer Conventional Commits.
    options:
      - label: Conventional Commits
        key: conventional
        value: "use Conventional Commits prefixes (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `test:`, ...) followed by a short imperative description, e.g. `feat: add team distribution solver`."
        description: Machine-readable history that works with changelog and release tooling.
      - label: Plain imperative
        key: plain
        value: "write a short imperative summary with no type prefix, e.g. `Add team distribution solver`."
        description: Plain style; fewer rules to follow, but nothing for tooling to parse.
  - id: scope
    question: "Should commit type prefixes carry a parenthesised scope naming what the change touches, e.g. `feat(parser): ...`?"
    when: {convention: conventional}
    scout: Check whether recent subjects already use scopes (git log --oneline -30 | grep -E '^[0-9a-f]+ \w+\('). If most do, recommend the matching scope option; if none do, recommend "No scope". With a clear module, package, or top-level folder structure and no history, recommend "Scope when it clarifies".
    options:
      - label: No scope
        value: "Commit scopes: do not add a parenthesised scope after the type; name the area in the description instead, e.g. `fix: handle empty input in parser`."
        description: Shortest subjects and nothing to keep consistent; fine for small or single-purpose projects.
      - label: Scope when it clarifies
        value: "Commit scopes: add a parenthesised scope after the type, e.g. `fix(parser): handle empty input`, only when the change is confined to one identifiable area (a module, package, or top-level folder) and the name is not obvious from the description. Omit it for cross-cutting changes. Reuse scope names already in the history rather than inventing variants."
        description: Scopes where they help readers filter history; skipped for cross-cutting or self-evident changes.
      - label: Always scope
        value: "Commit scopes: always add a parenthesised scope naming the area the change touches, e.g. `fix(parser): handle empty input`. Use the module, package, or top-level folder name, reuse scope names already in the history, and for cross-cutting changes use the most affected area."
        description: Uniform, filterable history (`git log --grep '(parser)'`), at the cost of picking and maintaining a scope vocabulary.
  - id: cadence
    question: When should Claude commit?
    scout: Check whether the history shows small frequent commits or large batched ones (git log --stat --oneline -20), and whether the user has a global CLAUDE.md preference. Without evidence, recommend proactive commits.
    options:
      - label: Proactively
        value: "Commit proactively when a logical chunk of work is done, without waiting to be asked each time. Keep each commit to one logical change."
        description: Small, reviewable commits; Claude commits on its own but never pushes.
      - label: Only when asked
        value: "Commit only when explicitly asked. When asked, keep each commit to one logical change."
        description: Full control over when history is written; Claude leaves changes in the working tree.
  - id: body
    question: When should commit messages have a body?
    scout: Look at how many recent commits have a body (git log -30 --format=%b). Recommend the matching habit; with no history, recommend body only when needed.
    options:
      - label: When needed
        value: "Add a body (after a blank line) only when the reason for the change is not obvious from the summary. Explain why, not what; the diff shows what."
        description: Keeps small commits small; bodies appear where they carry information.
      - label: Always
        value: "Always add a body after a blank line that explains why the change was made, not what it does; the diff shows what."
        description: Richer history for the cost of a longer message on every commit.
---

## Git commits

- Summary line: {{convention}}
- {{scope}}
- Avoid vague messages ("fix stuff", "update files"); the summary should say what changed.
- {{body}}
- {{cadence}}
