# Merging a session branch into main

Sibling worktrees share one repository, so refs are the one cheap, atomic thing every session can see. This recipe merges main into the session branch (where conflicts get resolved and tests re-run), then fast-forwards main, holding an advisory lock so two sessions do not do it at once. No history is rewritten.

## Peers

Before merging, and for the report's Notes, list the other worktrees: `git worktree list --porcelain`. For each other worktree's branch show ahead/behind main (`git rev-list --left-right --count main...<branch>`) and the files it changed that the session also changed (`git diff --name-only $(git merge-base main <branch>) <branch>` intersected with the session's). Overlap is the likely conflict source; mention it.

## Setup

- **Main branch**: `git symbolic-ref --short refs/remotes/origin/HEAD` minus `origin/`, else `main`.
- **Main worktree**: the first `worktree` entry of `git worktree list --porcelain`. Run main-side commands as `git -C <main-worktree> ...`.
- Both the session worktree and the main worktree must be clean (`git status --porcelain` empty) and main must be checked out in the main worktree. Otherwise stop and report; never stash or discard another worktree's changes.

## The lock

Ref `refs/worktree-task/merge-lock` points at a blob holding `<branch> <UTC timestamp>`. Creating a ref with an expected old value of "nothing" is atomic, so only one session can hold it.

```bash
LOCK=refs/worktree-task/merge-lock
BLOB=$(printf '%s %s\n' "$(git branch --show-current)" "$(date -u +%FT%TZ)" | git hash-object -w --stdin)
git update-ref "$LOCK" "$BLOB" ""      # fails if the ref already exists
```

- **Held by someone else**: read it with `git cat-file -p "$(git rev-parse --verify -q $LOCK)"`. Show the owner and age. Retry a few times with a short wait (the other merge is usually seconds); if still held, ask the user.
- **Stale** (older than about 15 minutes): the owner probably crashed. Say so and ask before breaking it (`git update-ref -d "$LOCK"`).
- **Release** with `git update-ref -d "$LOCK" "$BLOB"`; passing `$BLOB` makes sure a session only releases its own lock. Release on every exit path: success, failure, abort.

## Steps

1. Acquire the lock.
2. In the session worktree: `git merge <main>`.
   - Clean: continue.
   - Conflicts: resolve them (use the `resolving-merge-conflicts` skill if available). Resolve clear conflicts, where both sides' intent is compatible, yourself. If the sides contradict, or the right resolution is a judgement call, stop and ask the user. Commit the merge.
3. Re-run the project's tests on the merged result. If they fail, the merge is not done: fix what the merge broke if it is obvious, otherwise stop and report. Never loosen a test to get it through.
4. Fast-forward main: `git -C <main-worktree> merge --ff-only <session-branch>`.
   - If it refuses because main moved since step 2 (a peer merged without the lock, or the lock was broken), go back to step 2. Retry at most 3 times, then stop and report.
5. Release the lock.
6. Verify: `git -C <main-worktree> log -1 --oneline` is the session branch tip, and `git -C <main-worktree> status --porcelain` is empty.

Report the resulting commit, the tests result, which conflicts were resolved and how, and how long the lock was held.
