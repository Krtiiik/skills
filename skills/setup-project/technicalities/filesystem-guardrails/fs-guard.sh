#!/bin/sh
# PreToolUse hook for Bash and PowerShell: ask for confirmation before risky filesystem operations.
# Usage: fs-guard.sh <group>...   with groups from: delete move perms disk outside
# Reads the tool-call JSON on stdin and matches the raw text (no jq needed), so it
# may also ask when a risky command merely appears in a description; that is fine.
# Deletes, > redirects (and the outside-the-project check) skip disposable targets: temp folders
# and build or dependency output. Anything it cannot parse with confidence still asks.

set -f
input=$(cat)
# Undo JSON escaping: \\ -> /, drop \", \n and \r -> ;, \t -> space. Then hide package-manager
# and git "rm"/"remove" subcommands, which are not filesystem deletes.
body=$(printf '%s' "$input" | sed -e 's/\\\\/\//g' -e 's/\\"//g' -e 's/\\[nr]/;/g' -e 's/\\t/ /g' \
  -E -e 's/(^|[^[:alnum:]_.-])(git|npm|pnpm|yarn|docker|podman|dotnet|pip|winget|choco|scoop|brew|nuget)[[:space:]]+(rm|remove|del|uninstall)([[:space:]]|$)/\1\2 _ /g')
start='(^|[^[:alnum:]_.-])'
sp='[[:space:]]+'
proj=$(printf '%s' "${CLAUDE_PROJECT_DIR:-}" | tr '\\' '/' | tr -s '/')

hit() { printf '%s' "$body" | grep -Eiq -e "$1"; }

# Command segments for the verbs in $1 (alternation): verb plus arguments up to the next ; & | or quote.
segments() { printf '%s\n' "$body" | grep -Eio -e "${start}($1)${sp}[^|;&\"]*" | sed -E 's/^[^[:alnum:]]*//'; }

# Targets of the segments on stdin: one path per line, without verb, flags, and redirections.
targets() {
  while IFS= read -r seg; do
    set -- $(printf '%s' "$seg" | tr -s '/ ')
    shift
    for t in "$@"; do
      case $t in -*|[0-9]*\>*|\>*|/dev/null) continue ;; esac
      t=${t#\'}
      t=${t%\'}
      case $t in ?*/) t=${t%/} ;; esac
      printf '%s\n' "$t"
    done
  done
}

# Is $1 a throwaway location: inside a temp folder, or relative and inside build/dependency output?
disposable() {
  t=$1
  if [ -n "$proj" ]; then
    case $t in "$proj"/*) t=${t#"$proj"/} ;; esac
  fi
  case $t in *..*) return 1 ;; esac
  case $t in
    /tmp/?*|/var/tmp/?*|/private/var/folders/?*|*/AppData/Local/Temp/?*|*/appdata/local/temp/?*) return 0 ;;
    /*|~*|\$*|%*|[A-Za-z]:*) return 1 ;;
  esac
  for dir in node_modules bin obj dist build target out coverage .next .nuxt .svelte-kit .turbo .parcel-cache \
    .cache .gradle .venv .tox .mypy_cache .ruff_cache .pytest_cache __pycache__; do
    case $t in "$dir"|"$dir"/*|*/"$dir"|*/"$dir"/*) return 0 ;; esac
  done
  return 1
}

# Does $1 point outside the project folder (absolute, home, drive, or parent-relative)?
is_outside() {
  if [ -n "$proj" ]; then
    case $1 in "$proj"|"$proj"/*) return 1 ;; esac
  fi
  case $1 in
    /*|~*|[A-Za-z]:*|\$HOME*|\$\{HOME*|\$USERPROFILE*|\$env:*|%*|..|../*|*/../*|*/..) return 0 ;;
  esac
  return 1
}

delete_verbs='rm|rmdir|unlink|shred|del|erase|rd|ri|remove-item'

delete_risky() {
  segs=$(segments "$delete_verbs"
    printf '%s\n' "$body" | grep -Eio -e "${start}find${sp}[^|;&\"]*-delete[^|;&\"]*" | sed -E 's/^[^[:alnum:]]*//')
  [ -n "$segs" ] || return 1
  list=$(printf '%s\n' "$segs" | targets)
  [ -n "$list" ] || return 0
  if printf '%s\n' "$list" | while IFS= read -r t; do disposable "$t" || exit 1; done; then
    return 1
  fi
  return 0
}

outside_risky() {
  segs=$(segments "$delete_verbs|mv|move|move-item|truncate|chmod|chown|chgrp|icacls|takeown")
  [ -n "$segs" ] || return 1
  if printf '%s\n' "$segs" | targets | while IFS= read -r t; do
    if is_outside "$t" && ! disposable "$t"; then exit 1; fi
  done; then
    return 1
  fi
  return 0
}

# A single > redirect (not >>, 2>, or into /dev/null, $null, nul) overwrites its target,
# unless the target is disposable (temp folder, build or dependency output).
overwrites() {
  if printf '%s' "$body" | grep -Eio '[[:space:]]>[[:space:]]*[^[:space:]>&"|;]+' |
    sed -E 's/^[[:space:]]*>[[:space:]]*//' |
    while IFS= read -r t; do
      t=${t#\'}
      t=${t%\'}
      case $(printf '%s' "$t" | tr '[:upper:]' '[:lower:]') in /dev/null|\$null|nul) continue ;; esac
      disposable "$t" || exit 1
    done; then
    return 1
  fi
  return 0
}

reason=""
for group in "$@"; do
  case "$group" in
    delete)
      delete_risky &&
        reason="this permanently deletes files, bypassing the trash" ;;
    move)
      if hit "${start}(mv|move|move-item|truncate|tee|set-content|out-file|clear-content)${sp}" ||
        hit "${start}(cp|copy|copy-item|xcopy)${sp}([^|;&]*[[:space:]])?(-[[:alpha:]]*f[[:alpha:]]*|--force)([[:space:]\"]|\$)" ||
        overwrites; then
        reason="this can overwrite or relocate existing files"
      fi ;;
    perms)
      if hit "${start}(chown|chgrp|icacls|takeown|set-acl)${sp}" ||
        hit "${start}chmod${sp}([^|;&]*[[:space:]])?(-[[:alpha:]]*r[[:alpha:]]*|--recursive|0?777|0?666|([ao]|ugo)\+[rwx]*w)([[:space:]\"]|\$)"; then
        reason="this changes file permissions or ownership"
      fi ;;
    disk)
      if hit "${start}dd${sp}[^|;&]*(if|of)=" ||
        hit "${start}(mkfs[.[:alnum:]]*|fdisk|sfdisk|parted|wipefs|diskpart|format-volume|clear-disk|remove-partition|initialize-disk)([[:space:]\"]|\$)" ||
        hit "${start}format${sp}[[:alpha:]]:"; then
        reason="this can wipe or reformat a disk"
      fi ;;
    outside)
      outside_risky &&
        reason="this reaches outside the project folder" ;;
  esac
  [ -n "$reason" ] && break
done

if [ -n "$reason" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Confirm risky filesystem operation: %s"}}\n' "$reason"
fi
exit 0
