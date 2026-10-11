---
name: Issue Tracking
description: Where the project's issues live (GitHub or GitLab) and a short guide to the gh or glab CLI commands for them.
suggests: [issue-handling]
decisions:
  - id: platform
    question: Which platform hosts this project's issues?
    scout: Run `git remote -v` and read the host in the URLs. github.com means GitHub; gitlab.com or a host containing "gitlab" means GitLab; `.github/` suggests GitHub and `.gitlab-ci.yml` suggests GitLab for other hosts. Check whether `gh` or `glab` is installed (`gh --version`, `glab --version`) and mention it in the option description. Recommend the matching platform; with no remote, recommend neither.
    options:
      - label: GitHub
        key: gh
        value: GitHub, through the `gh` CLI
        description: Issues on github.com or GitHub Enterprise. Installs a `gh issue` guide.
        files:
          "{{location}}ISSUE-TRACKING.md": gh-issues.md
      - label: GitLab
        key: glab
        value: GitLab, through the `glab` CLI
        description: Issues on gitlab.com or a self-hosted GitLab. Installs a `glab issue` guide.
        files:
          "{{location}}ISSUE-TRACKING.md": glab-issues.md
  - id: location
    type: path
    question: Where should the issue-tracking guide live?
    scout: Look for an existing docs/ folder. The instruction file is already chosen, so the first option follows it; recommend it unless docs/ exists and holds human-facing documentation, in which case recommend keeping Claude's files out of it.
    options:
      - label: Beside the instruction file
        value: "{{claude_dir}}"
        description: Same folder as the CLAUDE file you chose (the project root for ./CLAUDE.md or CLAUDE.local.md, .claude/ for ./.claude/CLAUDE.md). Keeps Claude's files together.
      - label: docs/
        value: docs/
        description: Conventional and visible to humans too, but may mix with human-facing docs.
      - label: Project root
        value: ""
        description: File next to the code; clutters the root.
---

## Issue tracking

- Issues live on {{platform}}. Read `{{location:rel}}ISSUE-TRACKING.md` for the commands before your first use.
- When a `{{platform.key}}` command fails on authentication, report the error and let the user log in.
