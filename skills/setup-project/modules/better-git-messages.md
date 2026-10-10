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
        value: "use Conventional Commits prefixes (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `test:`, ...) followed by a short imperative description, e.g. `feat: add team distribution solver`."
        description: Machine-readable history that works with changelog and release tooling.
      - label: Plain imperative
        value: "write a short imperative summary with no type prefix, e.g. `Add team distribution solver`."
        description: Plain style; fewer rules to follow, but nothing for tooling to parse.
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
- Avoid vague messages ("fix stuff", "update files"); the summary should say what changed.
- {{body}}
- {{cadence}}
