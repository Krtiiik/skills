---
name: worktree-cleanup
description: Remove git worktrees and local branches that are already merged into main. Use when the user asks to clean up worktrees or merged branches.
---

Remove finished worktrees and their branches, nothing else. Do not ask which ones: merged means safe to remove.

1. **Find candidates.** From any checkout, run `git worktree list --porcelain` and `git branch --merged main`. A candidate is a linked worktree (not the main checkout, not the current one) whose branch is merged into `main` and whose `git -C <path> status --short` is empty. Also take merged local branches that have no worktree (never `main`). Skip everything else.
2. **Remove.** For each candidate, run these as separate commands, not chained, because the first can fail halfway:
   - `git worktree remove <path>`. On Windows this can unregister the worktree yet fail to delete the folder ("Permission denied", usually something still has it open). Check `git worktree list`: if the worktree is gone, carry on and report the leftover folder; if it is still listed, skip the candidate.
   - `git branch -d <branch>`.

   Never use `--force` or `-D`, and never touch remote branches. If git refuses, report it and leave the candidate alone.
3. **Report.** What was removed, what was skipped and why (unmerged, dirty, current), and any leftover folders for the user to delete once nothing has them open.
