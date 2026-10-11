---
name: setup-project
description: Assemble a project's CLAUDE.md, plus optional settings, hooks and doc files, from the guidelines (how Claude should work) and technicalities (project-specific commands and enforcement) the user picks. Use when the user wants to set up or bootstrap Claude for a project.
---

Build a project's Claude instruction file from **topics**: small Markdown files next to this file, in two categories:

- **Guidelines** (`guidelines/`): general rules for how Claude approaches work, such as commit habits, versioning, testing discipline and docs upkeep.
- **Technicalities** (`technicalities/`): the project's specific tooling and commands, such as test commands, the issue tracker's CLI, and the settings or hooks that enforce guardrails.

The user picks topics, answers each topic's decisions, and the skill writes the result. Both categories share one format and one workflow. Below, `<category>` stands for `guidelines` or `technicalities`.

## Topic format

Each `<category>/<id>.md` is a frontmatter block followed by the section text that gets inserted. An id is the filename without `.md` and is unique across both categories.

```markdown
---
name: Semantic Versioning
description: One line shown in the picker.
suggests: [other-topic-id]    # optional, picker hint only (may name a topic in either category)
settings: {}                  # optional, merged into the settings file whenever the topic is kept
files: {}                     # optional, copied into the project whenever the topic is kept (same shape as an option's)
decisions:                    # optional
  - id: scheme                # referenced in the body as {{scheme}}
    question: Which version scheme?
    scout: What to inspect in the project to pick the best-fit option.
    when: {other-decision: key}   # optional, ask this decision only if that decision's chosen option has this key
    multi: false              # optional, true lets the user pick several options
    type: text                # optional, "path" marks a folder decision (see Placeholders)
    options:
      - value: text substituted for {{scheme}}
        label: Short picker label   # optional, defaults to value
        key: short-id             # optional, name used by `when` and {{scheme.key}}
        scouted: true             # optional, the agent writes this option's value from scout findings (see below)
        description: Tradeoff shown to the user.
        when: {other-decision: key}   # optional, settings/files apply only if that decision's chosen option has this key
        settings:                 # optional, merged into the settings file when chosen
          permissions:
            ask: ["Bash(git push *)"]
        files:                    # optional, copied into the project when chosen
          .claude/hooks/guard.sh: guard.sh   # destination: source in <category>/<id>/
        seed: seed/context.md     # optional, sub-agent prompt in <category>/<id>/ (see step 10)
        run_seeds: true           # optional, choosing this option runs every chosen option's seed
---

## Section heading

Body text. Reference decisions with {{scheme}}.
```

Everything below the frontmatter is inserted verbatim except placeholders and lines that end up empty (see Placeholders). Adding a topic means adding one file to the fitting category, plus an optional `<category>/<id>/` folder holding the sources for `files` and `seed`; nothing else needs editing. A topic that needs both kinds (rules and commands, say) is two topics, one per category; they can `suggests` each other but cannot share decisions.

An option may carry `settings` (a JSON-compatible object, e.g. permission rules or hooks) and `files` (destination path in the project → source path inside `<category>/<id>/`). Both are applied only when that option is chosen, in step 9. A `files` destination may contain placeholders.

A topic may carry the same `settings` and `files` at its top level, for what the topic always needs regardless of the options chosen (a hook that every chosen group relies on). They apply whenever the topic is kept, in step 9, and placeholders in them resolve like in an option's.

An option's `when` maps a decision id to a `key` (or to the `value` of an option without a `key`). Its `settings` and `files` are applied only if the chosen option of that decision matches, so one decision's options can feed settings that depend on another decision. Ask the decision named in `when` before step 9 applies anything.

A decision may carry the same `when` at its own level. It is asked only if the named decision's chosen option matches; otherwise it is not asked, its placeholders resolve to empty text, and none of its options' `settings`, `files` or `seed` apply. Ask the decision it names in an earlier call.

An option may carry `seed`, the path of a prompt file in `<category>/<id>/` for a sub-agent that drafts the content of a file that option installed. Seeds run only if some chosen option of the topic has `run_seeds: true` (step 10).

An option may carry `scouted: true` for facts that only the project can supply, such as a test command. It has no `value`; the agent writes one from the decision's scout findings, as the complete text to insert (its `description` says what shape that text takes). The option is offered first, marked "(Recommended)", with the evidence in its description. If scouting found nothing, the option is not offered, and a decision left with a single option is not asked: that option applies. The user can edit the text through "Other". `label` is optional and defaults to the value.

## Placeholders

- `{{id}}` is the chosen option's `value`. For a `multi` decision it is the values of all chosen options joined by newlines, in option order.
- `{{id.key}}` is the `key` of the chosen option, or for a `multi` decision the keys of all chosen options joined by spaces, in option order. It also resolves inside `settings` strings (a hook command can list the enabled groups).
- `type: path` decisions hold a folder relative to the project root: forward slashes, no leading `./`, a trailing `/`, empty for the project root itself. The user's "Other" text is normalised to that form. Besides `{{id}}`, they provide `{{id:rel}}`, the same folder relative to the folder of the instruction file chosen in step 4 (`""` when they coincide, `../docs/` for `docs/` from `.claude/`). Use `{{id}}` in `files` destinations and `{{id:rel}}` in text and `@` imports, which resolve from the instruction file.
- `{{claude_dir}}` is built in: the folder of the instruction file chosen in step 4 relative to the project root (`.claude/` for `./.claude/CLAUDE.md`, empty otherwise). A path decision can use it as an option value to offer "beside the instruction file".
- A line whose only content, besides a list marker, is placeholders that resolve to empty text is dropped.

## Workflow

1. **Check existing setup.** Look in the project root (the git root, else the working directory) for these, and skip the step without a word if none exist:
   - Instruction files: `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`.
   - Settings: `.claude/settings.json`, `.claude/settings.local.json`.
   - Hook scripts: anything in `.claude/hooks/`.
   - Doc files topics install: `CONTEXT.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `TODO.md`, `CHANGELOG.md` and `ISSUE-TRACKING.md`, in the project root, `docs/` and `.claude/`.

   List what was found, then ask once with **AskUserQuestion**: **append** (Recommended), **overwrite** or **cancel**. The answer is the collision policy for the whole run, so later steps never ask about existing files again:
   - **Append.** Instruction file: new sections are added after the existing content. Settings: merged (step 9). Files a topic installs: any that already exist are kept as they are, and only missing ones are created.
   - **Overwrite.** The instruction file and the files topics install are replaced. Settings are still merged, never replaced, since they hold unrelated configuration.
   - **Cancel.** Stop without writing anything.
2. **Load topics.** Glob `guidelines/*.md` and `technicalities/*.md` beside this file and read each frontmatter. Sort each category by filename.
3. **Pick topics.** Ask with **AskUserQuestion**, one `multiSelect: true` question per 4 topics (the option limit), up to 4 questions per call. Ask guidelines first, then technicalities, using the question headers "Guidelines" and "Technicalities" (with "(1/2)" style suffixes when a category needs several questions). Each option's `label` is the topic `name`, its `description` the topic `description`; when a topic `suggests` another, append "pairs well with <name>" to the description. Never auto-select. Either category may be left empty; if nothing at all is selected, stop.
4. **Pick the target file.** Ask which file to write: `./CLAUDE.md` (Recommended), `./.claude/CLAUDE.md`, or `./CLAUDE.local.md`. If step 1 found an instruction file, recommend that one instead. Resolve against the project root. The step 1 policy decides whether an existing target is appended to or overwritten.
5. **Scout.** For each selected topic with decisions, follow every `scout` hint against the project (git tags, manifests, existing files, ...), except for decisions whose `when` cannot match. Facts are yours to find; use a sub-agent when the search is broad.
6. **Decide.** Ask each decision with **AskUserQuestion** (at most 4 per call, batch across topics, keep each topic's declaration order). Ask a decision with `when` in a call after the one that settles the decision it names, and skip it if the condition fails. Use the decision's `question` and `options` (an option's `label` if set, else its `value`); put the option the scouting supports first, end its label with "(Recommended)", and cite the evidence in its description. If scouting found nothing, recommend the first option. A `multi` decision is asked with `multiSelect: true`; mark recommended options in their description instead of reordering. A question holds at most 4 options, so split a `multi` decision with more across consecutive questions that repeat the question text with "(1/2)", "(2/2)"; the chosen options of all parts are the answer. Build each `scouted` option from the step 5 findings. The user can always answer "Other"; use their text as the value. For a `type: path` decision, drop options that resolve to the same folder as an earlier option. If the user selects nothing for a `multi` decision, drop that topic entirely: no body, settings, files or seeds, and ignore its other answers.
7. **Render.** Replace each placeholder as described above. Fail loudly if a placeholder has no matching decision rather than writing it out. Join topic bodies in selection order, all guidelines before all technicalities, separated by a blank line.
   - New file, or the step 1 policy is overwrite: start with `# <project name>` (from the manifest, else the folder name), a blank line, then the sections.
   - Policy is append and the target exists: add the sections after the existing content, separated by a blank line, leaving it untouched.
8. **Write the instruction file.** Write directly without a further confirmation.
9. **Apply settings and files.** Skip if no kept topic or chosen option carries `settings` or `files`.
   - **Settings.** Target `.claude/settings.json` in the project root, or `.claude/settings.local.json` when step 4 chose `CLAUDE.local.md`. Read it if it exists; if it is not valid JSON, stop and report rather than overwrite. Deep-merge every chosen `settings` object: objects merge key by key, arrays are concatenated without duplicates, existing values are preserved. Show the resulting diff (or the full content for a new file) and ask for approval with **AskUserQuestion** before writing; settings can change what Claude is allowed to run, so this step is never silent. If declined, print the snippet for the user to paste and continue.
   - **Files.** For each `files` entry, copy the source from `<category>/<id>/` to the destination (placeholders resolved) in the project root, creating folders as needed. If the destination exists, follow the step 1 policy without asking: overwrite replaces it, append keeps it and skips the copy. Mark scripts executable where the platform supports it.
   - **Local mode.** Applies when step 4 chose `CLAUDE.local.md` and settings were written to `.claude/settings.local.json` or files were copied into the project. Those are private or gitignored, and a fresh git worktree (used by sub-sessions and isolated agents) does not contain gitignored files. Ask once with **AskUserQuestion** whether to proceed, then:
     - Create or merge (no duplicate lines) a `.worktreeinclude` file in the project root, in `.gitignore` syntax, listing `.claude/settings.local.json` and `CLAUDE.local.md`, so Claude Code copies them into new worktrees. Copied hook scripts need no entry: `$CLAUDE_PROJECT_DIR` points at the original checkout.
     - Keep these setup files out of the project's history: append `.worktreeinclude` and every copied file to the repository's local exclude file (`git rev-parse --git-path info/exclude`), never to the tracked `.gitignore`. Skip lines already present.
10. **Seed.** Skip unless a chosen option has `run_seeds: true`. For every chosen option that has `seed` and whose files were installed, launch one general-purpose sub-agent, all in parallel in a single message. Its prompt is the contents of the seed file plus a line naming the installed file(s) it may edit. The sub-agents edit those files in place, with no further confirmation, and touch nothing else. Collect their short reports.
11. **Report.** Summarise: file path, the step 1 policy (if the step ran), guidelines and technicalities inserted, the value chosen for each decision (decisions skipped by `when` as "not asked"), and any settings or files applied, overwritten, kept as existing, or skipped, plus what each seed sub-agent drafted or flagged as unconfirmed. The user reviews via `git diff`.
