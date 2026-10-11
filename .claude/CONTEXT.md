# Context

<!--
Glossary for Claude: the terms and top-level concepts this project uses with a specific meaning.
- Define a term only if it means something particular here; skip ordinary words.
- One or two sentences each. Say what it is, not where it lives in the code.
- Keep the whole file short enough to read every session.
-->

## Language

**Skill**: A Claude Code skill shipped by this plugin (`grilling`, `setup-project`), defined by a `SKILL.md` with a name and trigger description.

**Topic**: A single Markdown file in one of `setup-project`'s category folders that contributes one section, and optionally decisions, settings and files, to a generated project instruction file. Either a Guideline or a Technicality; it replaces the old term "module".
_Avoid_: module, plugin, template, snippet

**Guideline**: A topic in `guidelines/` holding a general rule for how Claude approaches work (commit habits, versioning, testing discipline, docs upkeep).

**Technicality**: A topic in `technicalities/` holding project-specific tooling: commands, CLIs, and the settings or hooks that enforce a guardrail. A subject that needs both kinds is two topics, one per category, that suggest each other (`testing` and `test-commands`, `issue-handling` and `issue-tracking`).

**Instruction file**: The CLAUDE file that `setup-project` writes (`./CLAUDE.md`, `./.claude/CLAUDE.md` or `./CLAUDE.local.md`), assembled from the chosen topics' bodies, guidelines first.

**Decision**: A question a topic declares in its frontmatter, whose chosen option fills the topic body's `{{id}}` placeholders.

**Option**: One selectable answer to a decision, carrying a substitution `value` and optionally a `key`, `settings`, `files`, `seed` and `when`.

**Placeholder**: A `{{id}}`, `{{id.key}}`, `{{id:rel}}` or `{{claude_dir}}` token in a topic body that is replaced with a decision's answer; an unresolved one is a hard failure, not left in the output.

**Key**: A short id on an option that `when` conditions and `{{id.key}}` refer to, instead of its full `value`.

**When**: A condition mapping a decision id to an option key; the decision, option settings or files it is attached to apply only if that choice was made.

**Scout**: Inspecting the project (git history, manifests, existing files) before asking a decision, so a recommendation can be backed by evidence; also the `scout` frontmatter hint that says what to inspect.

**Scouted option**: An option with `scouted: true` and no fixed `value`; the agent writes its text from scout findings, and it is dropped if scouting found nothing.

**Seed**: A prompt file in a topic's folder that a sub-agent runs to draft the content of an installed doc file; it runs only if a chosen option has `run_seeds: true`.
_Avoid_: template (that is the empty file the seed fills)

**Settings**: A JSON object on an option, or on a topic for what it always needs, that `setup-project` deep-merges into `.claude/settings.json` (or `settings.local.json` in local mode) after user approval.

**Local mode**: The case where the target is `CLAUDE.local.md`, so setup files are private and gitignored and must be kept in `.worktreeinclude` and the local git exclude file.

**Guardrail**: A technicality (git or filesystem) that blocks dangerous git or filesystem operations automatically with a `PreToolUse` hook script on the Bash and PowerShell tools. The hook denies instead of asking so Claude never waits on a prompt; permission rules are not offered because they cannot express the exemptions below.

**Disposable target**: A literal absolute path strictly inside a temp folder (which includes the session scratchpad) or a Claude session worktree. Guardrail hooks let these through; anything relative, containing `..` or variables, or reached via a symlink or a preceding `cd` is not exempt, so a relative path cannot be used to pose as one.

**Project docs**: The Claude-facing files (CONTEXT, ARCHITECTURE, CONVENTIONS, TODO) installed by the Project Documentation guideline and kept current as the project changes.

**TODO Inbox / Suggested**: The two sections of the shared TODO.md; Inbox is written by the user, Suggested is proposed by Claude, and Claude works on items only when asked.

**Grilling**: Interviewing the user about a plan in plan mode, in rounds of clickable questions, until the design tree is fully explored.

**Design tree**: The model of a plan used by grilling, where each decision branches into the decisions that depend on it.

**Frontier**: The set of open decisions whose prerequisites are all settled, which grilling puts to the user together in one round.

**Round**: One pass of grilling: compute the frontier, ask it all (possibly across several AskUserQuestion calls), then update the tree.

## Relationships

- A **Skill** (`setup-project`) loads many **Topics**, each a **Guideline** or a **Technicality**; each Topic declares **Decisions**, each Decision offers **Options**.
- An **Option** may carry **Settings**, files, a **Seed** and a **When**; its **Key** is what other Options' **When** and `{{id.key}}` point at.
- A chosen Option's `value` replaces its **Placeholder** in the Topic body; Topic bodies are joined into the **Instruction file**.
- **Seeds** only draft files that an Option installed, which are the **Project docs**.
- **Grilling** walks a **Design tree** one **Round** at a time; each Round asks the **Frontier**.

## Ambiguities

- "Seed" names both the prompt file (`seed/context.md`) and the act of drafting; the file is the Seed, the drafting is "running seeds". The `seed` Decision in Project Documentation only chooses whether seeds run.
- "Decision" in `setup-project` is a topic question; in **Grilling** it is a node of the design tree. Context tells which.
- "Skill" can mean this plugin's skills or the externally installed ones; here it means the ones under `skills/`.
