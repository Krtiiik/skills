---
name: worktree-task
description: Run one task end to end in a git worktree session: do the work, commit, present a uniform report, and optionally merge into main safely alongside peer sessions. Use at the start of a worktree session with the task as the argument, or when the user says "worktree task".
---

Take one task from description to a reviewed, optionally merged result, inside a session that runs in its own git worktree. Other sessions may be doing the same in sibling worktrees, so never touch another worktree except as described in [merge.md](merge.md).

## 1. Intake

The argument is the task.

- No argument: ask what needs doing, in plain text.
- The description names a skill (e.g. "grill me on X", "use tdd"): invoke that skill first and let it shape the plan.
- Otherwise: write a short plan, confirm it through plan mode (**EnterPlanMode**, then **ExitPlanMode**) unless the task is trivial, and proceed on approval.

Check `git rev-parse --git-dir` against `git rev-parse --git-common-dir`. If they are equal, this is the main checkout, not a linked worktree: say so and ask whether to continue. Note the session branch (`git branch --show-current`).

## 2. Work

Do the work following the project's `CLAUDE.md`: commit each logical change as it completes, update the changelog and docs in the same change, ship tests with behaviour changes. Never push.

Run the project's tests before reporting. Take the command from the project's testing guidance; if there is none, look at the manifest, and if still nothing, report "no tests found" instead of inventing a command.

## 3. Report

When the work is done and committed, present the report in exactly this order and with these headings, every time:

1. **Summary**: what was done and why, 2-4 lines.
2. **Commits**: a table of `hash | subject | files changed` for every commit the session made on top of the base branch (`git log <base>..HEAD`).
3. **Tests**: command run, result, tests added or changed. Say plainly if none were run or none exist.
4. **Notes**: other nice-to-know: behaviour changes, docs and changelog touched, peer sessions found (see [merge.md](merge.md), "Peers"), anything surprising.
5. **To consider**: risks, follow-ups, open questions, things deliberately left out. Omit the heading's content with "Nothing" rather than padding.
6. **TODO suggestions**: only if `TODO.md` exists in the project root. List proposed items as `- [ ] task: why or context`, drawn from the "To consider" follow-ups. Do not edit `TODO.md` here.

## 4. Prompts

After the report, ask with **AskUserQuestion** (one call, skip a question that does not apply):

- **TODO**: append the suggested items to `## Suggested` in `TODO.md`? On yes, append them and commit as `docs: add suggested TODO items` on the session branch. Include the new commit in the merge below.
- **Merge**: merge the session branch into main? On no, stop; the work stays on the branch.

## 5. Merge

Only on a yes to the merge prompt. Follow [merge.md](merge.md). It merges main into the session branch, then fast-forwards main under an advisory lock so peer sessions merging at the same time cannot lose work.

After a successful merge, leave the branch and worktree in place, do not push, and say in one line that they can now be removed (removal needs the user's approval under the git guardrails).

## Rules

- Never rebase, amend, `reset --hard`, force-anything or push. If a guarded command is needed, follow the project's guardrail rules and ask.
- A stopped merge is a normal outcome: release the lock, report the state (branch, what blocked, how to continue) and leave the work intact.
