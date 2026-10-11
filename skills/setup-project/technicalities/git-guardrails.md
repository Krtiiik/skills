---
name: Git Guardrails
description: Pick which dangerous git operations are blocked automatically (push, history rewrites, discarding work, ...) by a hook on the Bash and PowerShell tools.
suggests: [better-git-messages, filesystem-guardrails]
decisions:
  - id: groups
    multi: true
    question: Which groups of dangerous git operations should be blocked automatically?
    scout: Check .claude/settings.json and .claude/settings.local.json for existing git permission rules or hooks, whether a POSIX shell is available for the hook (bash on PATH, or Git Bash on Windows; the hook needs it), and git log for force-pushes or amended commits. Recommend Publishing, Rewriting history, and Skipping safeguards unless the project's settings already cover them; recommend the other groups only when the project has submodules (.gitmodules), uses worktrees, or the user has said they want a strict setup.
    options:
      - key: publish
        label: Publishing
        value: "- **Publishing**: `git push`, including force-pushes and tag pushes."
        description: "git push in any form."
      - key: rewrite
        label: Rewriting history
        value: "- **Rewriting history**: `git reset --hard`, `git rebase`, `git commit --amend`, `git filter-branch`."
        description: "reset --hard, rebase, commit --amend, filter-branch."
      - key: skip
        label: Skipping safeguards
        value: "- **Skipping safeguards**: `--no-verify`, `--no-gpg-sign`, and `commit.gpgsign=false`."
        description: "--no-verify, --no-gpg-sign, commit.gpgsign=false."
      - key: discard
        label: Discarding work
        value: "- **Discarding work**: `git clean`, `git restore`, `git checkout -- <path>` or `git checkout .`, `git branch -D`, and `git stash drop` or `clear`."
        description: "clean, restore, checkout -- / checkout ., branch -D, stash drop/clear."
      - key: remote
        label: Remote/config changes
        value: "- **Remote and config changes**: `git remote add`, `set-url`, and `remove`, and `git config --global` or `--system`."
        description: "remote add/set-url/remove, config --global/--system."
      - key: nested
        label: Submodules & worktrees
        value: "- **Submodules and worktrees**: `git submodule deinit`, `git submodule update --force`, `git worktree remove`, and `git worktree prune`."
        description: "submodule deinit/update --force, worktree remove/prune. Removing worktrees under .claude/worktrees/ is allowed."
files:
  .claude/hooks/git-guard.sh: git-guard.sh
settings:
  hooks:
    PreToolUse:
      - matcher: Bash|PowerShell
        hooks:
          - type: command
            command: sh "$CLAUDE_PROJECT_DIR/.claude/hooks/git-guard.sh" {{groups.key}}
---

## Git guardrails

This project has git guardrails: certain dangerous git operations are blocked automatically, without a prompt. They are enforced by a `PreToolUse` hook (`.claude/hooks/git-guard.sh`, registered in the project's Claude settings) on both the Bash and PowerShell tools. The guarded groups are:

{{groups}}

**Allowed without prompting.** Work with these directly and don't treat a block as a reason to retry in another form:

- A guarded command that carries an explicit absolute `git -C <path>` strictly inside a temp folder (`/tmp`, `/var/tmp`, the folder in `TMPDIR`, `TEMP`, or `TMP`, which includes the session scratchpad) or inside a Claude session worktree (`<repo>/.claude/worktrees/<name>/...`). Use this for scratch repositories, e.g. `git -C /tmp/demo clean -fd`.
- `git worktree remove` of a path inside `<repo>/.claude/worktrees/`.

The hook checks the literal path in the command, so it can't be tricked and neither should you try:

- Write the full absolute path. A plain command in the current directory, a relative `-C`, `~`, variables (`$TMPDIR`, `$env:TEMP`), braces, a `..` or a wildcard in the path are never exempt, even when the current directory is itself a session worktree.
- Symlinks and junctions are resolved first; a link inside temp that points elsewhere is not exempt.
- Every git command in the line needs its own allowed `-C`; one plain `git push` after an exempt command still blocks.

- The user chose these guardrails deliberately. Do not avoid them: no rephrased or equivalent commands, aliases, `git -c` overrides, scripts or wrappers, other tools that call git, and no editing of the settings, the hook, or this file to switch them off.
- When a guardrail blocks something, say what the operation would have done and why you wanted it, then wait for the user. They may run it themselves or give new instructions. If they decline, do not run it or an equivalent.
- The hook matches raw command text, so a command that only mentions a guarded operation (in a commit message, say) can be blocked too; reword it.
- In a sub-session or agent, finish the rest of the task and report the blocked operation to the parent session or the user.
