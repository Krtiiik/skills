---
name: Filesystem Guardrails
description: Pick which dangerous filesystem operations are blocked automatically (deleting, overwriting, permission changes, disk-level commands, ...) by a hook on the Bash and PowerShell tools.
suggests: [git-guardrails]
decisions:
  - id: groups
    multi: true
    question: Which groups of dangerous filesystem operations should be blocked automatically?
    scout: Check .claude/settings.json and .claude/settings.local.json for existing rm/Remove-Item permission rules or hooks, whether a POSIX shell is available for the hook (bash on PATH, or Git Bash on Windows; the hook needs it), and whether the project is a git repository (deleted tracked files are recoverable, untracked ones are not). Recommend Deleting, Disk-level, and Outside the project unless the project's settings already cover them; recommend Moving & overwriting and Permissions & ownership only when the user has said they want a strict setup.
    options:
      - key: delete
        label: Deleting
        value: "- **Deleting**: `rm`, `rmdir`, `unlink`, `shred`, `find -delete`, and in PowerShell `Remove-Item`, `del`, and `rd`."
        description: "rm, rmdir, unlink, shred, find -delete, Remove-Item, del, rd. Temp, scratchpad, session-worktree, build-output, and git-tracked targets are allowed."
      - key: move
        label: Moving & overwriting
        value: "- **Moving and overwriting**: `mv`, forced `cp`, `truncate`, `tee`, and in PowerShell `Move-Item`, forced `Copy-Item`, `Set-Content`, `Out-File`, and `Clear-Content`, plus shell redirection (`>`) where the hook can match it."
        description: "mv, cp -f, truncate, tee, Move-Item, Set-Content, Out-File, and > redirects. Temp, scratchpad, session-worktree, git-tracked, and not-yet-existing targets are allowed."
      - key: perms
        label: Permissions & ownership
        value: "- **Permissions and ownership**: recursive or world-writable `chmod`, and `chown`, `chgrp`, `icacls`, `takeown`."
        description: "chmod -R / 777, chown, chgrp, icacls, takeown. Plain chmod +x is allowed, and so are temp, scratchpad, session-worktree, and git-tracked targets."
      - key: disk
        label: Disk-level
        value: "- **Disk-level**: `dd`, `mkfs`, `fdisk`, `parted`, `wipefs`, and in Windows `format` and `diskpart` (including `Format-Volume` and `Clear-Disk`)."
        description: "dd, mkfs, fdisk, parted, wipefs, format, diskpart, Format-Volume, Clear-Disk. Never exempt."
      - key: outside
        label: Outside the project
        value: "- **Outside the project**: deleting, moving, or changing permissions of anything outside the project folder: absolute paths, `~`, `$HOME`, drive roots, and `..` (for example `rm -rf ~`)."
        description: "Targets outside the project: absolute paths, ~, $HOME, drive roots, .. . Temp, scratchpad, and session-worktree targets are allowed."
files:
  .claude/hooks/fs-guard.sh: fs-guard.sh
settings:
  hooks:
    PreToolUse:
      - matcher: Bash|PowerShell
        hooks:
          - type: command
            command: sh "$CLAUDE_PROJECT_DIR/.claude/hooks/fs-guard.sh" {{groups.key}}
---

## Filesystem guardrails

This project has filesystem guardrails: certain dangerous or irreversible filesystem operations are blocked automatically, without a prompt. They are enforced by a `PreToolUse` hook (`.claude/hooks/fs-guard.sh`, registered in the project's Claude settings) on both the Bash and PowerShell tools. The guarded groups are:

{{groups}}

**Allowed without prompting.** These targets are exempt from every group above except Disk-level, so work with them directly and don't treat a block as a reason to retry in another form:

- Anything strictly inside a temp folder: `/tmp`, `/var/tmp`, the folder in `TMPDIR`, `TEMP`, or `TMP` (on Windows `%LOCALAPPDATA%\Temp`). The session scratchpad lives there, so it is covered. The temp folder itself is not.
- Anything strictly inside a Claude session worktree: `<repo>/.claude/worktrees/<name>/...`. The worktree folder itself and `<name>/*` are not.
- For deletes only, relative build or dependency output: `node_modules`, `bin`, `obj`, `dist`, `build`, `target`, `out`, `coverage`, `.next`, `.cache`, `.venv`, `__pycache__`, and similar.
- Files inside the project that git tracks, since git can restore them. A folder counts only when everything under it is tracked (no untracked or ignored files, no submodule). Uncommitted changes to a tracked file are not recoverable, so commit first if they matter. The guardrail files (`.git`, `.claude/hooks`, the Claude settings, `CLAUDE.md`) are never unlocked this way.
- For moves and overwrites only, a project path that does not exist yet (a rename destination, a new file). Overwriting an existing untracked file is still blocked.

The hook checks the literal path in the command, so it can't be tricked and neither should you try:

- Write the full absolute path (for example the scratchpad path from the system prompt). Relative paths into temp or worktrees, `~`, variables (`$TMPDIR`, `$env:TEMP`, `%TEMP%`), and braces are not exempt. Relative paths to tracked files work, unless the command changes directory first.
- A `..` anywhere in the path, or a wildcard in a folder part, is never exempt. A wildcard in the last part is fine only below the exempt folder (`/tmp/x/*`, not `/tmp/*`), and never unlocks tracked files: name them.
- Symlinks and junctions are resolved first; a link inside temp that points elsewhere is not exempt.
- A command that changes directory first (`cd`, `pushd`, `Set-Location`) gets no relative exemption: use absolute paths instead of `cd x && rm -rf build`.
- Every target of a command must be exempt; one outside target blocks the whole command.

- The user chose these guardrails deliberately. Do not avoid them: no rephrased or equivalent commands, aliases, scripts or wrappers, other tools or languages that touch the same files (`python -c`, `xargs`, `robocopy`, ...), and no editing of the settings, the hook, or this file to switch them off.
- When a guardrail blocks something, say what the operation would have done and why you wanted it, then wait for the user. They may run it themselves or give new instructions. If they decline, do not run it or an equivalent.
- The hook matches raw command text, so a command that only mentions a guarded operation (in a commit message, say) can be blocked too; reword it.
- In a sub-session or agent, finish the rest of the task and report the blocked operation to the parent session or the user.
