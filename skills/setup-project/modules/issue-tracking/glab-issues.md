# Issue tracking with `glab`

Run these from inside the repository, or add `-R GROUP/PROJECT` (nested groups: `GROUP/SUBGROUP/PROJECT`) to target another one. An issue is addressed by number (`12`) or URL.

## Read

```sh
glab auth status                                # confirm login
glab issue list                                 # open issues
glab issue list -A -l bug -a someuser -P 50     # all states, label, assignee, per page
glab issue list -c                              # closed only
glab issue list --search "login error"          # search title and description
glab issue view 12                              # title, description, metadata
glab issue view 12 -c                           # include comments
glab issue list -O json                         # JSON output; view takes -F json and --jq
```

## Write

Ask the user first unless they requested the action explicitly.

```sh
glab issue create -t "Short title" --description-file body.md --no-editor
glab issue note 12 -m "Comment text"
glab issue update 12 -t "New title" -l bug -a someuser   # -u removes a label, --unassign clears assignees
glab issue close 12
glab issue reopen 12
```

## Tips

- Pass long text with `--description-file <file>` and `--no-editor`; shell quoting mangles newlines and quotes, especially on Windows.
- Reference an issue in a commit or MR with `Closes #12` to close it on merge.
- Leave `--web` alone; it opens a browser. `glab issue note` without `-m` opens an editor, so always pass `-m`.
- On a self-hosted GitLab, `glab` reads the host from the git remote; `glab auth login --hostname <host>` signs in, and `GITLAB_HOST` selects the host outside a repository.
