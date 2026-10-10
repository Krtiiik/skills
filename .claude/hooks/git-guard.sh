#!/bin/sh
# PreToolUse hook for Bash: ask for confirmation before risky git operations.
# Usage: git-guard.sh <group>...   with groups from: publish rewrite skip discard remote nested
# Reads the tool-call JSON on stdin and matches the raw text (no jq needed), so it
# may also ask when a risky command merely appears in a description; that is fine.

input=$(cat)
git='(^|[^[:alnum:]_-])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+'
# Claude's own sub-session worktrees; the JSON may carry either slash style.
own_worktree='\.claude[/\\]+worktrees[/\\]'

hit() { printf '%s' "$input" | grep -Eq -e "$1"; }

reason=""
for group in "$@"; do
  case "$group" in
    publish)
      hit "${git}push\b" &&
        reason="git push is visible to others (this includes force-pushes and tag pushes)" ;;
    rewrite)
      hit "${git}(reset[^|;&]*--hard|rebase|filter-branch|commit[^|;&]*--amend)" &&
        reason="this rewrites git history" ;;
    skip)
      hit '--no-verify|--no-gpg-sign|commit\.gpgsign=false' &&
        reason="this skips git hooks or commit signing" ;;
    discard)
      hit "${git}(clean\b|restore\b|stash[[:space:]]+(drop|clear)\b|branch[^|;&]*(-D\b|--delete[^|;&]*--force|--force[^|;&]*--delete)|checkout[^|;&]*([[:space:]]--[[:space:]]|[[:space:]]\.([[:space:]\"\\\\;&|]|\$)))" &&
        reason="this can discard uncommitted or unmerged work" ;;
    remote)
      hit "${git}(remote[[:space:]]+(add|set-url|remove|rm)\b|config[^|;&]*--(global|system)\b)" &&
        reason="this changes remotes or global git configuration" ;;
    nested)
      if hit "${git}(submodule[[:space:]]+deinit|submodule[^|;&]*--force)"; then
        reason="this can delete submodule content"
      elif hit "${git}worktree[[:space:]]+(remove|prune)\b"; then
        hit "${git}worktree[[:space:]]+remove[^|;&]*${own_worktree}" ||
          reason="this removes a worktree that Claude did not create"
      fi ;;
  esac
  [ -n "$reason" ] && break
done

if [ -n "$reason" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Confirm risky git operation: %s"}}\n' "$reason"
fi
exit 0
