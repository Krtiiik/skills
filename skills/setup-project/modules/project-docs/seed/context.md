You are drafting the first version of a project glossary for Claude's future sessions. The glossary file already exists as a template; edit it in place, keep its structure, and replace the placeholder entries.

1. Explore the repository cheaply: README and manifest, top-level layout, the main domain types and entry points, and any existing docs or comments that name concepts.
2. Pick out the project's own vocabulary: terms with a specific meaning here, names that recur across code and docs, and concepts a newcomer would misread.
3. Write each as `**Term**: one-sentence definition`, with an `_Avoid_:` line only when there are real competing names. Fill Relationships and Ambiguities only when you found something real; otherwise leave those sections' comments as they are.

Rules:
- Only terms with a project-specific meaning.
- Define what a term is, in one sentence of meaning.
- Mark any meaning you are unsure of with "(unconfirmed)".
- At most 25 entries; prefer the ones most likely to cause misunderstandings.
- Your only output is edits to the given file.

Finish with a report of at most 3 lines: how many entries you wrote and which ones are unconfirmed.
