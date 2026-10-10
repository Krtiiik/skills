---
name: Git Guardrails
description: Pick which dangerous git operations need your confirmation (push, history rewrites, discarding work, ...) and enforce them with permission rules or a hook.
suggests: [better-git-messages, filesystem-guardrails]
decisions:
  - id: groups
    multi: true
    question: Which groups of dangerous git operations should need your confirmation?
    scout: Check .claude/settings.json and .claude/settings.local.json for existing git permission rules, and git log for force-pushes or amended commits. Recommend Publishing, Rewriting history, and Skipping safeguards unless the project's settings already cover them; recommend the other groups only when the project has submodules (.gitmodules), uses worktrees, or the user has said they want a strict setup.
    options:
      - key: publish
        label: Publishing
        value: "- **Publishing**: `git push`, including force-pushes and tag pushes, which are visible to others or can trigger release automation."
        description: "git push in any form."
        when: {enforcement: rules}
        settings:
          permissions:
            ask: ["Bash(git push)", "Bash(git push *)"]
      - key: rewrite
        label: Rewriting history
        value: "- **Rewriting history**: `git reset --hard`, `git rebase`, `git commit --amend`, `git filter-branch`."
        description: "reset --hard, rebase, commit --amend, filter-branch."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(git reset --hard)"
              - "Bash(git reset --hard *)"
              - "Bash(git rebase *)"
              - "Bash(git commit --amend*)"
              - "Bash(git commit * --amend*)"
              - "Bash(git filter-branch *)"
      - key: skip
        label: Skipping safeguards
        value: "- **Skipping safeguards**: `--no-verify`, `--no-gpg-sign`, and `commit.gpgsign=false`, which bypass git hooks and commit signing."
        description: "--no-verify, --no-gpg-sign, commit.gpgsign=false."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(git * --no-verify*)"
              - "Bash(git * --no-gpg-sign*)"
              - "Bash(git -c commit.gpgsign=false *)"
      - key: discard
        label: Discarding work
        value: "- **Discarding work**: `git clean`, `git restore`, `git checkout -- <path>` or `git checkout .`, `git branch -D`, and `git stash drop` or `clear`, which destroy uncommitted or unmerged work."
        description: "clean, restore, checkout -- / checkout ., branch -D, stash drop/clear."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(git clean *)"
              - "Bash(git restore *)"
              - "Bash(git checkout -- *)"
              - "Bash(git checkout .)"
              - "Bash(git branch -D *)"
              - "Bash(git branch --delete --force *)"
              - "Bash(git stash drop*)"
              - "Bash(git stash clear*)"
      - key: remote
        label: Remote/config changes
        value: "- **Remote and config changes**: `git remote add`, `set-url`, and `remove`, and `git config --global` or `--system`, which change where code is sent or how git behaves everywhere."
        description: "remote add/set-url/remove, config --global/--system."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(git remote add *)"
              - "Bash(git remote set-url *)"
              - "Bash(git remote remove *)"
              - "Bash(git remote rm *)"
              - "Bash(git config --global *)"
              - "Bash(git config --system *)"
      - key: nested
        label: Submodules & worktrees
        value: "- **Submodules and worktrees**: `git submodule deinit`, `git submodule update --force`, `git worktree remove`, and `git worktree prune`, which can delete checked-out content. Worktrees Claude created itself under `.claude/worktrees/` are exempt when a hook enforces the guardrails; permission rules cannot make that exception, so there every worktree removal asks."
        description: "submodule deinit/update --force, worktree remove/prune. A hook exempts Claude's own .claude/worktrees/; permission rules cannot."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(git submodule deinit *)"
              - "Bash(git submodule update --force*)"
              - "Bash(git submodule update * --force*)"
              - "Bash(git worktree remove *)"
              - "Bash(git worktree prune*)"
  - id: enforcement
    question: How should the guardrails be enforced?
    scout: Check .claude/settings.json and .claude/settings.local.json for existing permissions or hooks, and whether a POSIX shell is available (bash on PATH, or Git Bash on Windows). Recommend permission rules unless a hook already exists, the Submodules & worktrees group was chosen (only the hook can exempt Claude's own worktrees), or flag-level matching is clearly wanted.
    options:
      - key: rules
        label: Permission rules
        value: "permission rules (`permissions.ask` in the project's Claude settings), so the harness itself prompts for each matching command"
        description: Writes permissions.ask rules to the settings file. Simple and cross-platform; matches by command prefix, so it can miss flags in unusual positions.
      - key: hook
        label: Hook
        value: "a `PreToolUse` hook on Bash (`.claude/hooks/git-guard.sh`, registered in the project's Claude settings) that asks for confirmation on matching commands"
        description: Copies a small shell script to .claude/hooks/ and registers it as a PreToolUse hook on Bash. Matches flags anywhere in the command and can exempt Claude's own worktrees, but needs a POSIX shell.
        files:
          .claude/hooks/git-guard.sh: git-guard.sh
        settings:
          hooks:
            PreToolUse:
              - matcher: Bash
                hooks:
                  - type: command
                    command: sh "$CLAUDE_PROJECT_DIR/.claude/hooks/git-guard.sh" {{groups.key}}
---

## Git guardrails

This project has git guardrails: certain dangerous git operations need the user's confirmation. They are enforced by {{enforcement}}. The guarded groups are:

{{groups}}

- The user chose these guardrails deliberately. Do not avoid them: no rephrased or equivalent commands, aliases, `git -c` overrides, scripts or wrappers, other tools that call git, and no editing of the settings, the hook, or this file to switch them off.
- When a guardrail triggers, say what the operation will do and wait for the user's answer. If the user declines, do not run it or an equivalent.
- In a sub-session or agent where nobody can answer the prompt, stop at the guarded operation, finish the rest of the task, and report the blocked operation to the parent session or the user.
