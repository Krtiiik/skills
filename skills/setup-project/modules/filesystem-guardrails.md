---
name: Filesystem Guardrails
description: Pick which dangerous filesystem operations need your confirmation (deleting, overwriting, permission changes, disk-level commands, ...) and enforce them with permission rules or a hook.
suggests: [git-guardrails]
decisions:
  - id: groups
    multi: true
    question: Which groups of dangerous filesystem operations should need your confirmation?
    scout: Check .claude/settings.json and .claude/settings.local.json for existing rm/Remove-Item permission rules or hooks, and whether the project is a git repository (deleted tracked files are recoverable, untracked ones are not). Recommend Deleting and Disk-level unless the project's settings already cover them; recommend Outside the project only when a POSIX shell is available for the hook (it cannot be enforced with permission rules); recommend Moving & overwriting and Permissions & ownership only when the user has said they want a strict setup.
    options:
      - key: delete
        label: Deleting
        value: "- **Deleting**: `rm`, `rmdir`, `unlink`, `shred`, `find -delete`, and in PowerShell `Remove-Item`, `del`, and `rd`, which bypass the trash and cannot be undone. Deleting disposable locations (temp folders, scratchpads, and build or dependency output such as `node_modules`, `bin`, `obj`, `dist`, `build`, `target`) is exempt when a hook enforces the guardrails; permission rules cannot make that exception, so there every delete asks."
        description: "rm, rmdir, unlink, shred, find -delete, Remove-Item, del, rd. A hook exempts temp and build-output folders; permission rules cannot."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(rm *)"
              - "Bash(rmdir *)"
              - "Bash(unlink *)"
              - "Bash(shred *)"
              - "Bash(find * -delete*)"
              - "PowerShell(Remove-Item *)"
              - "PowerShell(ri *)"
              - "PowerShell(rm *)"
              - "PowerShell(rmdir *)"
              - "PowerShell(del *)"
              - "PowerShell(erase *)"
              - "PowerShell(rd *)"
      - key: move
        label: Moving & overwriting
        value: "- **Moving and overwriting**: `mv`, forced `cp`, `truncate`, `tee`, and in PowerShell `Move-Item`, forced `Copy-Item`, `Set-Content`, `Out-File`, and `Clear-Content`, which replace existing files without a backup. Shell redirection (`>`) is guarded only when a hook enforces the guardrails; permission rules cannot match it."
        description: "mv, cp -f, truncate, tee, Move-Item, Set-Content, Out-File. A hook also catches > redirects; permission rules cannot."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(mv *)"
              - "Bash(cp -f *)"
              - "Bash(cp --force *)"
              - "Bash(cp * -f*)"
              - "Bash(cp * --force*)"
              - "Bash(truncate *)"
              - "Bash(tee *)"
              - "PowerShell(Move-Item *)"
              - "PowerShell(mi *)"
              - "PowerShell(move *)"
              - "PowerShell(Copy-Item * -Force*)"
              - "PowerShell(Set-Content *)"
              - "PowerShell(Out-File *)"
              - "PowerShell(Clear-Content *)"
      - key: perms
        label: Permissions & ownership
        value: "- **Permissions and ownership**: recursive or world-writable `chmod`, and `chown`, `chgrp`, `icacls`, `takeown`, which can lock you out of files or expose them. A hook lets plain `chmod +x` and `chmod 644` through; permission rules match only by prefix, so they miss flags in unusual positions."
        description: "chmod -R / 777, chown, chgrp, icacls, takeown. A hook lets plain chmod +x through."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(chmod -R *)"
              - "Bash(chmod --recursive *)"
              - "Bash(chmod * -R*)"
              - "Bash(chmod 777 *)"
              - "Bash(chmod 666 *)"
              - "Bash(chmod a+w *)"
              - "Bash(chmod o+w *)"
              - "Bash(chown *)"
              - "Bash(chgrp *)"
              - "Bash(icacls *)"
              - "Bash(takeown *)"
              - "PowerShell(icacls *)"
              - "PowerShell(takeown *)"
              - "PowerShell(Set-Acl *)"
      - key: disk
        label: Disk-level
        value: "- **Disk-level**: `dd`, `mkfs`, `fdisk`, `parted`, `wipefs`, and in Windows `format` and `diskpart` (including `Format-Volume` and `Clear-Disk`), which wipe or reformat whole devices and partitions."
        description: "dd, mkfs, fdisk, parted, wipefs, format, diskpart, Format-Volume, Clear-Disk."
        when: {enforcement: rules}
        settings:
          permissions:
            ask:
              - "Bash(dd *)"
              - "Bash(mkfs *)"
              - "Bash(mkfs.* *)"
              - "Bash(fdisk *)"
              - "Bash(sfdisk *)"
              - "Bash(parted *)"
              - "Bash(wipefs *)"
              - "Bash(diskpart*)"
              - "PowerShell(diskpart*)"
              - "PowerShell(format *:*)"
              - "PowerShell(Format-Volume *)"
              - "PowerShell(Clear-Disk *)"
              - "PowerShell(Remove-Partition *)"
              - "PowerShell(Initialize-Disk *)"
      - key: outside
        label: Outside the project
        value: "- **Outside the project**: deleting, moving, or changing permissions of anything outside the project folder: absolute paths, `~`, `$HOME`, drive roots, and `..` (for example `rm -rf ~`). Temp folders are exempt. This group is enforced only by a hook; permission rules cannot match on paths, so with them it does nothing."
        description: "Targets outside the project: absolute paths, ~, $HOME, drive roots, .. . Hook only; permission rules cannot match paths."
  - id: enforcement
    question: How should the guardrails be enforced?
    scout: Check .claude/settings.json and .claude/settings.local.json for existing permissions or hooks, and whether a POSIX shell is available (bash on PATH, or Git Bash on Windows). Recommend the hook when a POSIX shell is available, since only it can exempt temp and build-output deletes and enforce Outside the project; otherwise recommend permission rules.
    options:
      - key: rules
        label: Permission rules
        value: "permission rules (`permissions.ask` in the project's Claude settings), so the harness itself prompts for each matching command"
        description: Writes permissions.ask rules to the settings file for the Bash and PowerShell tools. Simple and cross-platform; matches by command prefix, so it can miss flags in unusual positions, asks for every delete, and cannot enforce Outside the project.
      - key: hook
        label: Hook
        value: "a `PreToolUse` hook on Bash and PowerShell (`.claude/hooks/fs-guard.sh`, registered in the project's Claude settings) that asks for confirmation on matching commands"
        description: Copies a small shell script to .claude/hooks/ and registers it as a PreToolUse hook on Bash and PowerShell. Matches flags anywhere in the command, exempts temp and build-output deletes, and enforces Outside the project, but needs a POSIX shell.
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

This project has filesystem guardrails: certain dangerous or irreversible filesystem operations need the user's confirmation. They are enforced by {{enforcement}}. The guarded groups are:

{{groups}}

- The user chose these guardrails deliberately. Do not avoid them: no rephrased or equivalent commands, aliases, scripts or wrappers, other tools or languages that touch the same files (`python -c`, `xargs`, `robocopy`, ...), and no editing of the settings, the hook, or this file to switch them off.
- When a guardrail triggers, say what the operation will do and wait for the user's answer. If the user declines, do not run it or an equivalent.
- In a sub-session or agent where nobody can answer the prompt, stop at the guarded operation, finish the rest of the task, and report the blocked operation to the parent session or the user.
