---
name: setup-project
description: Set up Claude for a project by assembling a CLAUDE.md, and optionally settings and hook files, from modules the user picks (Semantic Versioning, Keep a Changelog, Better Git Messages, ...). Use when the user wants to set up, create, or bootstrap a CLAUDE.md, Claude instructions, or Claude project configuration.
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
    options:
      - value: text substituted for {{scheme}}
        label: Short picker label   # optional, defaults to value
        description: Tradeoff shown to the user.
        settings:                 # optional, merged into the settings file when chosen
          permissions:
            ask: ["Bash(git push *)"]
        files:                    # optional, copied into the project when chosen
          .claude/hooks/guard.sh: guard.sh   # destination: source in modules/<id>/
---

## Section heading

Body text. Reference decisions with {{scheme}}.
```

Everything below the frontmatter is inserted verbatim except `{{id}}` placeholders. Adding a module means adding one file, plus an optional `modules/<id>/` folder holding the sources for `files:`; nothing else needs editing.

An option may carry `settings` (a JSON-compatible object, e.g. permission rules or hooks) and `files` (destination path in the project → source path inside `modules/<id>/`). Both are applied only when that option is chosen, in step 9.

## Workflow

1. **Load modules.** Glob `modules/*.md` beside this file and read each frontmatter. Sort by filename.
2. **Pick modules.** Ask with **AskUserQuestion**, one `multiSelect: true` question per 4 modules (the option limit), up to 4 questions per call. Each option's `label` is the module `name`, its `description` the module `description`; when a module `suggests` another, append "pairs well with <name>" to the description. Never auto-select. If nothing is selected, stop.
3. **Scout.** For each selected module with decisions, follow every `scout` hint against the project (git tags, manifests, existing files, ...). Facts are yours to find; use a sub-agent when the search is broad.
4. **Decide.** Ask each decision with **AskUserQuestion** (at most 4 per call, batch across modules). Use the decision's `question` and `options` (an option's `label` if set, else its `value`); put the option the scouting supports first, end its label with "(Recommended)", and cite the evidence in its description. If scouting found nothing, recommend the first option. The user can always answer "Other"; use their text as the value.
5. **Pick the target file.** Ask which file to write: `./CLAUDE.md` (Recommended), `./.claude/CLAUDE.md`, or `./CLAUDE.local.md`. Resolve against the project root (the git root, else the working directory).
6. **Existing file.** If the target exists, ask: append, overwrite, or cancel. Cancel stops without writing anything.
7. **Render.** Replace each `{{id}}` with the chosen value. Fail loudly if a placeholder has no matching decision rather than writing it out. Join module bodies in selection order, separated by a blank line.
   - New or overwritten file: start with `# <project name>` (from the manifest, else the folder name), a blank line, then the sections.
   - Append: add the sections after the existing content, separated by a blank line, leaving it untouched.
8. **Write the instruction file.** Write directly without a further confirmation.
9. **Apply settings and files.** Skip if no chosen option carries `settings` or `files`.
   - **Settings.** Target `.claude/settings.json` in the project root, or `.claude/settings.local.json` when step 5 chose `CLAUDE.local.md`. Read it if it exists; if it is not valid JSON, stop and report rather than overwrite. Deep-merge every chosen `settings` object: objects merge key by key, arrays are concatenated without duplicates, existing values are preserved. Show the resulting diff (or the full content for a new file) and ask for approval with **AskUserQuestion** before writing; settings can change what Claude is allowed to run, so this step is never silent. If declined, print the snippet for the user to paste and continue.
   - **Files.** For each `files` entry, copy the source from `modules/<id>/` to the destination in the project root, creating folders as needed. Ask before overwriting an existing file. Mark scripts executable where the platform supports it.
10. **Report.** Summarise: file path, modules inserted, the value chosen for each decision, and any settings or files applied (or skipped). The user reviews via `git diff`.
