# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-10-16

### Changed

- `filesystem-guardrails` hook: git-tracked targets inside the project are now allowed for the delete, move and permission groups (a folder only if everything under it is tracked, with no untracked or ignored files and no submodule). Moves and overwrites may also create paths that do not exist yet. The guardrail files (`.git`, `.claude/hooks`, the Claude settings, `CLAUDE.md`) are never unlocked, and wildcards, `..`, variables and relative paths after a `cd` still get no exemption. Relative paths resolve against the `cwd` the hook receives.

## [0.4.0] - 2026-10-11

### Added

- `auto-commit` guideline: new `attribution` decision to keep or suppress Claude's `Co-Authored-By` commit trailer and "Generated with Claude Code" pull request line. Suppressing it also sets Claude Code's `attribution` setting to empty.

## [0.3.0] - 2026-10-11

### Added

- `bump-version` skill: suggests a semver bump from the changelog's `[Unreleased]` entries, asks the user to confirm it, updates the changelog and version files, commits and tags the release, then offers to push the commit and tag.
- `worktree-task` skill: runs one task in a worktree session (optionally via another skill such as `grilling`), commits, presents a uniform report (summary, commits, tests, notes, to consider, TODO suggestions), and on request merges main into the branch and fast-forwards main under a git-ref advisory lock so peer sessions do not lose work.
- `setup-project` now checks upfront for existing Claude files (instruction files, settings, hooks, topic doc files), lists them, and asks once whether to append, overwrite or cancel.
- `worktree-cleanup` skill: lists linked worktrees and local branches already merged into main (clean worktrees only) and removes them without asking. Copes with Windows leaving the worktree folder behind.
- `setup-project` topics may carry top-level `settings` and `files`, applied whenever the topic is kept rather than per chosen option.
- `filesystem-guardrails` hook: targets that are literal absolute paths strictly inside a temp folder (including the Claude scratchpad) or a Claude session worktree are allowed for the delete, move, permission, and outside-the-project groups. Relative paths, `..`, variables, symlinks that lead out, and paths after a `cd` get no exemption.
- `git-guardrails` hook: guarded commands with an explicit absolute `git -C <path>` inside a temp folder or a Claude session worktree are allowed, and `git worktree remove` is allowed only for paths under `.claude/worktrees/`.

### Changed

- `setup-project` splits its "modules" into two categories of topics: **guidelines** (general rules for how Claude approaches work) in `guidelines/` and **technicalities** (project-specific commands, tooling and enforcement) in `technicalities/`. The picker asks guidelines first, then technicalities, and the generated file lists guidelines before technicalities.
- `testing` is now two topics: the guideline `testing` (rules) and the technicality `test-commands` (how tests are organised and run). `issue-tracking` likewise splits into the guideline `issue-handling` (read freely, ask before writing) and the technicality `issue-tracking` (platform and CLI guide).
- The `git-guardrails` and `filesystem-guardrails` topics are now technicalities; `project-docs`, `auto-commit`, `better-git-messages`, `keep-a-changelog` and `semver` are guidelines.
- The upfront choice replaces the separate "existing instruction file" prompt and the per-file overwrite prompts. Settings are always merged and still shown for approval.
- `git-guardrails` hook now covers the PowerShell tool as well as Bash, denies risky operations outright instead of asking, and the topic no longer offers permission-rule enforcement.
- `filesystem-guardrails` hook now denies risky operations outright instead of asking, and the topic no longer offers permission-rule enforcement. It also no longer asks about `>` redirects into temp folders or build and dependency output (they are allowed).
- The guardrail text in the generated CLAUDE.md lists the allowed locations, so Claude uses them directly instead of retrying after a block.

## [0.2.0] - 2026-10-11

### Added

- `setup-project` module `issue-tracking`: work with GitHub or GitLab issues through the `gh` or `glab` CLI, with a short command guide for each and an approval rule for anything that writes.
- `setup-project` module `auto-commit`: choose when Claude commits on its own and whether large work may be split into several commits.
- `setup-project` module `testing`: describes how the project's tests are organised and run (all, related to a change, single, fast vs slow), found by scouting the project, plus general testing guidelines.

### Changed

- The commit cadence decision moved out of `better-git-messages` into the new `auto-commit` module.

### Fixed

- Corrected a broken link path in the `setup-project` skill description.

## [0.1.0] - 2026-10-10

### Added

- `krtiiik` plugin with a marketplace manifest, installable via `/plugin marketplace add Krtiiik/skills`.
- `grilling` skill: grills the user about a plan, decision, or idea in clickable question rounds, ending in plan-review approval. Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT).
- `setup-project` skill (initially `init-claude-md`): assembles a project's `CLAUDE.md`, plus optional settings, hooks, and doc files, from the modules the user picks.
- `setup-project` modules:
  - `semver`: default to Semantic Versioning, never bump unprompted, tag releases on request.
  - `keep-a-changelog`: maintain a `CHANGELOG.md` updated with every user-facing change.
  - `better-git-messages`: consistent commit message convention, optional conditional commit scopes, and commit bodies that explain why.
  - `git-guardrails`: choose which dangerous git operations need confirmation, enforced by permission rules or a hook.
  - `filesystem-guardrails`: choose which dangerous filesystem operations need confirmation, enforced by permission rules or a hook.
  - `project-docs`: Claude-facing docs (glossary, architecture, conventions, shared TODO list) that Claude keeps current.
