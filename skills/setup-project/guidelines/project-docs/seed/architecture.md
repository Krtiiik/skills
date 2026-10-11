You are drafting the first version of an architecture document for Claude's future sessions. The file already exists as a template; edit it in place, keep its structure, and replace the placeholder text.

1. Explore the repository: README and manifest, top-level layout, entry points, how the main parts call or depend on each other, configuration and build setup, and the git history for clues about why things are the way they are (`git log`, large or refactoring commits).
2. Fill Overview with what the system does and its main parts, in a few sentences.
3. Fill Components and flow with how the parts relate and how data or control moves between them, in prose or a small list. Name components by role, not by file.
4. Fill Design notes only with choices whose reason you can actually support from the code, comments, docs or history. Format: `**Choice.** Why, and what was rejected.`

Rules:
- Record only what the source can't tell a newcomer: intent, relationships and rationale.
- Give only rationale the code, docs or history supports. When a design looks odd and the reason is unclear, write the Design note and end it with "(reason unconfirmed)".
- Keep it short; a page is plenty.
- Your only output is edits to the given file.

Finish with a report of at most 3 lines: what you covered and which notes are unconfirmed.
