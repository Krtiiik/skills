# Context

<!--
Glossary for Claude: the terms and top-level concepts this project uses with a specific meaning.
- Define a term only if it means something particular here; skip ordinary words.
- One or two sentences each. Say what it is, not where it lives in the code.
- Keep the whole file short enough to read every session.
-->

## Language

**Skill**: A Claude Code skill shipped by this plugin (`grilling`, `setup-project`, `bump-version`), defined by a `SKILL.md` with a name and trigger description.

**Module**: A single Markdown file in `setup-project`'s `modules/` folder that contributes one section, and optionally decisions, settings and files, to a generated project instruction file.
_Avoid_: plugin, template, snippet

**Instruction file**: The CLAUDE file that `setup-project` writes (`./CLAUDE.md`, `./.claude/CLAUDE.md` or `./CLAUDE.local.md`), assembled from the chosen modules' bodies.

**Decision**: A question a module declares in its frontmatter, whose chosen option fills the module body's `{{id}}` placeholders.

**Option**: One selectable answer to a decision, carrying a substitution `value` and optionally a `key`, `settings`, `files`, `seed` and `when`.

**Placeholder**: A `{{id}}`, `{{id.key}}`, `{{id:rel}}` or `{{claude_dir}}` token in a module body that is replaced with a decision's answer; an unresolved one is a hard failure, not left in the output.

**Key**: A short id on an option that `when` conditions and `{{id.key}}` refer to, instead of its full `value`.

**When**: A condition mapping a decision id to an option key; the decision, option settings or files it is attached to apply only if that choice was made.

**Scout**: Inspecting the project (git history, manifests, existing files) before asking a decision, so a recommendation can be backed by evidence; also the `scout` frontmatter hint that says what to inspect.

**Scouted option**: An option with `scouted: true` and no fixed `value`; the agent writes its text from scout findings, and it is dropped if scouting found nothing.

**Seed**: A prompt file in a module's folder that a sub-agent runs to draft the content of an installed doc file; it runs only if a chosen option has `run_seeds: true`.
_Avoid_: template (that is the empty file the seed fills)

**Settings**: A JSON object on an option that `setup-project` deep-merges into `.claude/settings.json` (or `settings.local.json` in local mode) after user approval.

**Local mode**: The case where the target is `CLAUDE.local.md`, so setup files are private and gitignored and must be kept in `.worktreeinclude` and the local git exclude file.

**Guardrail**: A module group that makes dangerous git or filesystem operations ask for confirmation, enforced either as permission rules or as a hook script.

**Enforcement**: The guardrail decision between permission `rules` (static `ask` patterns) and a `hook` (a shell script that can express exemptions rules cannot).

**Project docs**: The Claude-facing files (CONTEXT, ARCHITECTURE, CONVENTIONS, TODO) installed by the Project Documentation module and kept current as the project changes.

**TODO Inbox / Suggested**: The two sections of the shared TODO.md; Inbox is written by the user, Suggested is proposed by Claude, and Claude works on items only when asked.

**Grilling**: Interviewing the user about a plan in plan mode, in rounds of clickable questions, until the design tree is fully explored.

**Design tree**: The model of a plan used by grilling, where each decision branches into the decisions that depend on it.

**Frontier**: The set of open decisions whose prerequisites are all settled, which grilling puts to the user together in one round.

**Round**: One pass of grilling: compute the frontier, ask it all (possibly across several AskUserQuestion calls), then update the tree.

## Relationships

- A **Skill** (`setup-project`) loads many **Modules**; each Module declares **Decisions**, each Decision offers **Options**.
- An **Option** may carry **Settings**, files, a **Seed** and a **When**; its **Key** is what other Options' **When** and `{{id.key}}` point at.
- A chosen Option's `value` replaces its **Placeholder** in the Module body; Module bodies are joined into the **Instruction file**.
- **Seeds** only draft files that an Option installed, which are the **Project docs**.
- **Grilling** walks a **Design tree** one **Round** at a time; each Round asks the **Frontier**.

## Ambiguities

- "Seed" names both the prompt file (`seed/context.md`) and the act of drafting; the file is the Seed, the drafting is "running seeds". The `seed` Decision in Project Documentation only chooses whether seeds run.
- "Decision" in `setup-project` is a module question; in **Grilling** it is a node of the design tree. Context tells which.
- "Skill" can mean this plugin's skills or the externally installed ones; here it means the ones under `skills/`.
