---
name: worktree-cleanup
description: Remove git worktrees and local branches that are already merged into main. Use when the user asks to clean up worktrees or merged branches.
---

Remove finished worktrees and their branches, nothing else.

1. **Find candidates.** From any checkout, run `git worktree list --porcelain` and `git branch --merged main`. A candidate is a linked worktree (not the main checkout, not the current one) whose branch is merged into `main` and whose `git -C <path> status --short` is empty. Also list merged branches that have no worktree. Skip everything else, and mention skipped worktrees with the reason (unmerged, dirty, current).
2. **Ask.** List the candidates (path, branch) and ask with **AskUserQuestion** which to remove (`multiSelect: true`). If there are none, say so and stop.
3. **Remove.** For each chosen candidate: `git worktree remove <path>` then `git branch -d <branch>`. Never use `--force` or `-D`; if git refuses, report it and leave the candidate alone. Never touch remote branches.
4. **Report.** What was removed and what was left.
