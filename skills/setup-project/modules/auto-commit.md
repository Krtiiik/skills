---
name: Auto Commit
description: Decide when Claude commits on its own and whether large work may be split into several commits.
suggests: [better-git-messages, git-guardrails]
decisions:
  - id: cadence
    question: When should Claude commit?
    scout: Check whether the history shows small frequent commits or large batched ones (git log --stat --oneline -20), and whether the user has a global CLAUDE.md preference. Without evidence, recommend proactive commits.
    options:
      - label: Proactively
        value: "Commit proactively when a logical chunk of work is done, without waiting to be asked each time. Never push unless asked."
        description: Small, reviewable commits; Claude commits on its own but never pushes.
      - label: Only when asked
        value: "Commit only when explicitly asked. Otherwise leave changes in the working tree."
        description: Full control over when history is written; Claude leaves changes in the working tree.
  - id: split
    question: May Claude split large work into several commits?
    scout: Check whether recent commits are small and focused or whether big changes land as one commit (git log --stat --oneline -20). Recommend the matching habit; without evidence, recommend several commits.
    options:
      - label: Several commits
        value: "Split large work into several commits, one per logical change, each leaving the project in a working state. Do not squash unrelated changes into one commit."
        description: Reviewable, bisectable history; large tasks produce a series of commits.
      - label: One commit
        value: "Commit the work of one request as a single commit, even when it is large."
        description: One commit per task; simpler history, but big diffs to review and revert.
---

## Committing

- {{cadence}}
- {{split}}
