---
name: grilling
description: Grill the user about a plan, decision, or idea through clickable AskUserQuestion rounds in plan mode, ending in plan-review approval. Use when the user wants to stress-test their thinking or says "grill".
---

Interview the user relentlessly until you share their understanding of the plan. Model it as a **design tree**: every decision branches into the decisions that depend on it.

Start by calling **EnterPlanMode**, unless the session is already in plan mode. The whole grilling runs inside it.

## Rounds

Work the tree in **rounds**. The **frontier** is every open decision whose prerequisites are all settled: the questions you can ask _now_ without guessing at answers you haven't heard.

Each round:

1. Compute the frontier.
2. Put the whole frontier to the user with **AskUserQuestion**, never as questions in your response text. A call takes at most 4 questions, so split a larger frontier across consecutive calls. That is still one round, with the frontier fixed until the last call is answered.
3. Read the answers, `annotations` included. Notes attached to a selection are part of the answer and may reshape the tree.
4. Update the tree. Settled decisions unblock the questions that depended on them. A question that depends on a decision still open this round belongs to a later round.

Repeat until the frontier is empty.

## Writing a question

For each frontier question, set:

- `question`: the question itself.
- `header`: a short label (≤12 chars) naming the decision, e.g. "Auth method".
- `options`: 2-4 mutually exclusive choices, each with a `label` and a `description` that spells out the tradeoff. Put your recommended answer first and end its label with "(Recommended)". Cover the recommended path and the main real alternatives; the user can always answer in free text via "Other". Set `multiSelect: true` only when the decision genuinely isn't either/or.
- `preview` (optional, per option): use it when the choice is between concrete artifacts that are easier to compare side by side than to describe: code snippets, config or schema shapes, ASCII layouts, API signatures. Single-select only. Abstract decisions get prose descriptions instead.

## Facts and decisions

Facts are yours to find; decisions are the user's.

- **Facts** (filesystem, tools, environment): dispatch a sub-agent to look them up. A running exploration is an unsettled prerequisite, so only the questions downstream of it wait for its report. Ask the rest of the frontier now.
- **Decisions**: put each to the user and wait for the answer.

## Finishing

The session is done when the frontier is empty: every branch of the design tree has been visited, and every decision is either answered by the user or recorded as an assumption. Act on the result only after the user confirms the shared understanding, and get that confirmation through the plan-review UI, not in plain text or AskUserQuestion:

1. Write the settled decisions to the plan file, one line per branch (decision → answer, plus the user's reason if given), followed by a list of your assumptions.
2. Call **ExitPlanMode** so the user can approve, or reject with inline comments.

Approval confirms the shared understanding. Rejection comments are new input: fold them into the tree, run another round from the new frontier, then repeat this section.
