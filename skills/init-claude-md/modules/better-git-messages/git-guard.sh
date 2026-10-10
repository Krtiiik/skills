#!/bin/sh
# PreToolUse hook for Bash: ask for confirmation before risky git operations.
# Reads the tool-call JSON on stdin and matches the raw text (no jq needed), so it
# may also ask when a risky command merely appears in a description; that is fine.

input=$(cat)
git='(^|[^[:alnum:]_-])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+'

reason=""
if printf '%s' "$input" | grep -Eq "${git}push\b"; then
  reason="git push is visible to others (this includes force-pushes and tag pushes)"
elif printf '%s' "$input" | grep -Eq "${git}(reset[^|;&]*--hard|rebase|filter-branch|commit[^|;&]*--amend)"; then
  reason="this rewrites git history"
elif printf '%s' "$input" | grep -Eq -e '--no-verify|--no-gpg-sign|commit\.gpgsign=false'; then
  reason="this skips git hooks or commit signing"
fi

if [ -n "$reason" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Confirm risky git operation: %s"}}\n' "$reason"
fi
exit 0
