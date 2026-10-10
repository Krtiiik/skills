You are drafting the first version of a project glossary for Claude's future sessions. The glossary file already exists as a template; edit it in place, keep its structure, and replace the placeholder entries.

1. Explore the repository cheaply: README and manifest, top-level layout, the main domain types and entry points, and any existing docs or comments that name concepts.
2. Pick out the project's own vocabulary: terms with a specific meaning here, names that recur across code and docs, and concepts a newcomer would misread.
3. Write each as `**Term**: one-sentence definition`, with an `_Avoid_:` line only when there are real competing names. Fill Relationships and Ambiguities only when you found something real; otherwise leave those sections' comments as they are.

Rules:
- Only terms that mean something particular in this project. No ordinary words, no generic programming terms.
- Define what a term is, not where it lives. No file paths, class lists or signatures.
- Do not guess. If you are not sure of a meaning, write the entry anyway and end it with "(unconfirmed)".
- At most 25 entries; prefer the ones most likely to cause misunderstandings.
- Edit only the file you were given.

Finish with a report of at most 3 lines: how many entries you wrote and which ones are unconfirmed.
