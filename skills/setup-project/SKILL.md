---
name: setup-project
description: Set up Claude for a project by assembling a CLAUDE.md, and optionally settings, hook and documentation files, from modules the user picks (Semantic Versioning, Keep a Changelog, Better Git Messages, Git Guardrails, Filesystem Guardrails, Project Documentation, ...). Use when the user wants to set up, create, or bootstrap a CLAUDE.md, Claude instructions, or Claude project configuration.
---

Build a project's Claude instruction file from **modules**: small Markdown files in `modules/` next to this file. The user picks modules, answers each module's decisions, and the skill writes the result.

## Module format

Each `modules/<id>.md` is a frontmatter block followed by the section text that gets inserted.

```markdown
---
name: Semantic Versioning
description: One line shown in the picker.
suggests: [other-module-id]   # optional, picker hint only
decisions:                    # optional
  - id: scheme                # referenced in the body as {{scheme}}
    question: Which version scheme?
    scout: What to inspect in the project to pick the best-fit option.
    multi: false              # optional, true lets the user pick several options
    type: text                # optional, "path" marks a folder decision (see Placeholders)
    options:
      - value: text substituted for {{scheme}}
        label: Short picker label   # optional, defaults to value
        key: short-id             # optional, name used by `when` and {{scheme.key}}
        description: Tradeoff shown to the user.
        when: {other-decision: key}   # optional, settings/files apply only if that decision's chosen option has this key
        settings:                 # optional, merged into the settings file when chosen
          permissions:
            ask: ["Bash(git push *)"]
        files:                    # optional, copied into the project when chosen
          .claude/hooks/guard.sh: guard.sh   # destination: source in modules/<id>/
        seed: seed/context.md     # optional, sub-agent prompt in modules/<id>/ (see step 10)
        run_seeds: true           # optional, choosing this option runs every chosen option's seed
---

## Section heading

Body text. Reference decisions with {{scheme}}.
```

Everything below the frontmatter is inserted verbatim except placeholders and lines that end up empty (see Placeholders). Adding a module means adding one file, plus an optional `modules/<id>/` folder holding the sources for `files` and `seed`; nothing else needs editing.

An option may carry `settings` (a JSON-compatible object, e.g. permission rules or hooks) and `files` (destination path in the project → source path inside `modules/<id>/`). Both are applied only when that option is chosen, in step 9. A `files` destination may contain placeholders.

An option's `when` maps a decision id to a `key` (or to the `value` of an option without a `key`). Its `settings` and `files` are applied only if the chosen option of that decision matches, so one decision's options can feed settings that depend on another decision. Ask the decision named in `when` before step 9 applies anything.

An option may carry `seed`, the path of a prompt file in `modules/<id>/` for a sub-agent that drafts the content of a file that option installed. Seeds run only if some chosen option of the module has `run_seeds: true` (step 10).

## Placeholders

- `{{id}}` is the chosen option's `value`. For a `multi` decision it is the values of all chosen options joined by newlines, in option order.
- `{{id.key}}` is the `key` of the chosen option, or for a `multi` decision the keys of all chosen options joined by spaces, in option order. It also resolves inside `settings` strings (a hook command can list the enabled groups).
- `type: path` decisions hold a folder relative to the project root: forward slashes, no leading `./`, a trailing `/`, empty for the project root itself. The user's "Other" text is normalised to that form. Besides `{{id}}`, they provide `{{id:rel}}`, the same folder relative to the folder of the instruction file chosen in step 3 (`""` when they coincide, `../docs/` for `docs/` from `.claude/`). Use `{{id}}` in `files` destinations and `{{id:rel}}` in text and `@` imports, which resolve from the instruction file.
- `{{claude_dir}}` is built in: the folder of the instruction file chosen in step 3 relative to the project root (`.claude/` for `./.claude/CLAUDE.md`, empty otherwise). A path decision can use it as an option value to offer "beside the instruction file".
- A line whose only content is placeholders that resolve to empty text is dropped.

## Workflow

1. **Load modules.** Glob `modules/*.md` beside this file and read each frontmatter. Sort by filename.
2. **Pick modules.** Ask with **AskUserQuestion**, one `multiSelect: true` question per 4 modules (the option limit), up to 4 questions per call. Each option's `label` is the module `name`, its `description` the module `description`; when a module `suggests` another, append "pairs well with <name>" to the description. Never auto-select. If nothing is selected, stop.
3. **Pick the target file.** Ask which file to write: `./CLAUDE.md` (Recommended), `./.claude/CLAUDE.md`, or `./CLAUDE.local.md`. Resolve against the project root (the git root, else the working directory).
4. **Existing file.** If the target exists, ask: append, overwrite, or cancel. Cancel stops without writing anything.
5. **Scout.** For each selected module with decisions, follow every `scout` hint against the project (git tags, manifests, existing files, ...). Facts are yours to find; use a sub-agent when the search is broad.
6. **Decide.** Ask each decision with **AskUserQuestion** (at most 4 per call, batch across modules, keep each module's declaration order). Use the decision's `question` and `options` (an option's `label` if set, else its `value`); put the option the scouting supports first, end its label with "(Recommended)", and cite the evidence in its description. If scouting found nothing, recommend the first option. A `multi` decision is asked with `multiSelect: true`; mark recommended options in their description instead of reordering. A question holds at most 4 options, so split a `multi` decision with more across consecutive questions that repeat the question text with "(1/2)", "(2/2)"; the chosen options of all parts are the answer. The user can always answer "Other"; use their text as the value. For a `type: path` decision, drop options that resolve to the same folder as an earlier option. If the user selects nothing for a `multi` decision, drop that module entirely: no body, settings, files or seeds, and ignore its other answers.
7. **Render.** Replace each placeholder as described above. Fail loudly if a placeholder has no matching decision rather than writing it out. Join module bodies in selection order, separated by a blank line.
   - New or overwritten file: start with `# <project name>` (from the manifest, else the folder name), a blank line, then the sections.
   - Append: add the sections after the existing content, separated by a blank line, leaving it untouched.
8. **Write the instruction file.** Write directly without a further confirmation.
9. **Apply settings and files.** Skip if no chosen option carries `settings` or `files`.
   - **Settings.** Target `.claude/settings.json` in the project root, or `.claude/settings.local.json` when step 3 chose `CLAUDE.local.md`. Read it if it exists; if it is not valid JSON, stop and report rather than overwrite. Deep-merge every chosen `settings` object: objects merge key by key, arrays are concatenated without duplicates, existing values are preserved. Show the resulting diff (or the full content for a new file) and ask for approval with **AskUserQuestion** before writing; settings can change what Claude is allowed to run, so this step is never silent. If declined, print the snippet for the user to paste and continue.
   - **Files.** For each `files` entry, copy the source from `modules/<id>/` to the destination (placeholders resolved) in the project root, creating folders as needed. Ask before overwriting an existing file. Mark scripts executable where the platform supports it.
   - **Local mode.** Applies when step 3 chose `CLAUDE.local.md` and settings were written to `.claude/settings.local.json` or files were copied into the project. Those are private or gitignored, and a fresh git worktree (used by sub-sessions and isolated agents) does not contain gitignored files. Ask once with **AskUserQuestion** whether to proceed, then:
     - Create or merge (no duplicate lines) a `.worktreeinclude` file in the project root, in `.gitignore` syntax, listing `.claude/settings.local.json` and `CLAUDE.local.md`, so Claude Code copies them into new worktrees. Copied hook scripts need no entry: `$CLAUDE_PROJECT_DIR` points at the original checkout.
     - Keep these setup files out of the project's history: append `.worktreeinclude` and every copied file to the repository's local exclude file (`git rev-parse --git-path info/exclude`), never to the tracked `.gitignore`. Skip lines already present.
10. **Seed.** Skip unless a chosen option has `run_seeds: true`. For every chosen option that has `seed` and whose files were installed, launch one general-purpose sub-agent, all in parallel in a single message. Its prompt is the contents of the seed file plus a line naming the installed file(s) it may edit. The sub-agents edit those files in place, with no further confirmation, and touch nothing else. Collect their short reports.
11. **Report.** Summarise: file path, modules inserted, the value chosen for each decision, and any settings or files applied (or skipped), plus what each seed sub-agent drafted or flagged as unconfirmed. The user reviews via `git diff`.
