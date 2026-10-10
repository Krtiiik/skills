# krtiiik

## Committing

- Commit proactively when a logical chunk of work is done, without waiting to be asked each time. Never push unless asked.
- Split large work into several commits, one per logical change, each leaving the project in a working state. Do not squash unrelated changes into one commit.

## Git commits

- Summary line: use Conventional Commits prefixes (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `test:`, ...) followed by a short imperative description, e.g. `feat: add team distribution solver`.
- Commit scopes: add a parenthesised scope after the type naming the skill being worked on, e.g. `fix(setup-project): correct link path`. Omit it for changes that do not belong to a single skill.
- Avoid vague messages ("fix stuff", "update files"); the summary should say what changed.
- Add a body (after a blank line) only when the reason for the change is not obvious from the summary. Explain why, not what; the diff shows what.

## Filesystem guardrails

This project has filesystem guardrails: certain dangerous or irreversible filesystem operations need the user's confirmation. They are enforced by a `PreToolUse` hook (`.claude/hooks/fs-guard.sh`, registered in the project's Claude settings). The guarded groups are:

- **Deleting**: `rm`, `rmdir`, `unlink`, `shred`, `find -delete`, and in PowerShell `Remove-Item`, `del`, and `rd`.
- **Moving and overwriting**: `mv`, forced `cp`, `truncate`, `tee`, and in PowerShell `Move-Item`, forced `Copy-Item`, `Set-Content`, `Out-File`, and `Clear-Content`, plus shell redirection (`>`) where the enforcement can match it.
- **Permissions and ownership**: recursive or world-writable `chmod`, and `chown`, `chgrp`, `icacls`, `takeown`.
- **Disk-level**: `dd`, `mkfs`, `fdisk`, `parted`, `wipefs`, and in Windows `format` and `diskpart` (including `Format-Volume` and `Clear-Disk`).
- **Outside the project**: deleting, moving, or changing permissions of anything outside the project folder: absolute paths, `~`, `$HOME`, drive roots, and `..` (for example `rm -rf ~`).

- The user chose these guardrails deliberately. Do not avoid them: no rephrased or equivalent commands, aliases, scripts or wrappers, other tools or languages that touch the same files (`python -c`, `xargs`, `robocopy`, ...), and no editing of the settings, the hook, or this file to switch them off.
- When a guardrail triggers, say what the operation will do and wait for the user's answer. If the user declines, do not run it or an equivalent.
- In a sub-session or agent where nobody can answer the prompt, stop at the guarded operation, finish the rest of the task, and report the blocked operation to the parent session or the user.

## Git guardrails

This project has git guardrails: certain dangerous git operations need the user's confirmation. They are enforced by a `PreToolUse` hook (`.claude/hooks/git-guard.sh`, registered in the project's Claude settings). The guarded groups are:

- **Publishing**: `git push`, including force-pushes and tag pushes.
- **Rewriting history**: `git reset --hard`, `git rebase`, `git commit --amend`, `git filter-branch`.
- **Skipping safeguards**: `--no-verify`, `--no-gpg-sign`, and `commit.gpgsign=false`.
- **Discarding work**: `git clean`, `git restore`, `git checkout -- <path>` or `git checkout .`, `git branch -D`, and `git stash drop` or `clear`.
- **Remote and config changes**: `git remote add`, `set-url`, and `remove`, and `git config --global` or `--system`.
- **Submodules and worktrees**: `git submodule deinit`, `git submodule update --force`, `git worktree remove`, and `git worktree prune`.

- The user chose these guardrails deliberately. Do not avoid them: no rephrased or equivalent commands, aliases, `git -c` overrides, scripts or wrappers, other tools that call git, and no editing of the settings, the hook, or this file to switch them off.
- When a guardrail triggers, say what the operation will do and wait for the user's answer. If the user declines, do not run it or an equivalent.
- In a sub-session or agent where nobody can answer the prompt, stop at the guarded operation, finish the rest of the task, and report the blocked operation to the parent session or the user.

## Changelog

- Maintain `CHANGELOG.md` in the Keep a Changelog format (keepachangelog.com).
- Log every user-facing change (feature, fix, behavior change) under an `## [Unreleased]` section at the top, added in the same commit as the change itself, not batched later.
- Only when explicitly asked for a release, move `[Unreleased]` under a new `## [<version>] - YYYY-MM-DD` heading.

## Project documentation

Docs for Claude, kept in the repository:

- @CONTEXT.md: glossary of the project's terms and top-level concepts. Use these terms exactly in code, commits and conversation.
- `TODO.md`: task list shared between the user and you, with `## Inbox` (written by the user) and `## Suggested` (proposed by you) sections and items as `- [ ] task: why or context`.
  - Work on items only when the user asks ("work on the TODO", "do item 3"); never start them unprompted.
  - When asked to find bugs, suggest features or leave a handoff, add the findings under `## Suggested` for the user to triage. Don't add items unprompted.
  - Tick an item (`- [x]`) in the same change that completes it.

Maintaining them:

- Record only what the source can't tell you: intent, vocabulary, rationale and non-obvious relationships. Don't list files, signatures or anything a quick search would find.
- Update a doc in the same change that makes it stale or introduces something worth recording (a new term, a design choice and its reason, a convention). Don't wait to be asked and don't batch it for later.
- Keep entries short. When a doc and the code disagree, trust the code and fix the doc.

## Versioning

- Use Semantic Versioning (semver.org) with MAJOR.MINOR.PATCH version numbers.
- Never bump the version on your own initiative. Only when explicitly asked for a release or version bump, bump per semver rules and tag the commit (`git tag -a v<version> -m "v<version>"`). You may mention in one line that something looks release-worthy, but don't act on it.
