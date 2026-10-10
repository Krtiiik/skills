---
name: Testing
description: How the project's tests are organised and run (all, related to a change, single, fast vs slow), found by scouting, plus general testing guidelines.
suggests: [better-git-messages]
decisions:
  - id: layout
    question: How should CLAUDE.md describe the project's test framework and layout?
    scout: Find the test framework and where tests live. Check manifests (package.json devDependencies and scripts, pyproject.toml, pytest.ini, tox.ini, *.csproj, Cargo.toml, go.mod, Gemfile, pom.xml, build.gradle) and CI config (.github/workflows, .gitlab-ci.yml). List the test folders and file naming (git ls-files | grep -iE 'test|spec'), and whether tests mirror the source tree or sit in a separate project.
    options:
      - label: Detected layout
        scouted: true
        description: One sentence naming the framework, where tests live and how files are named, e.g. "Tests use xUnit in `tests/<Project>.Tests/`, mirroring `src/`, files named `*Tests.cs`."
      - label: Skip
        value: ""
        description: Leave the layout out of CLAUDE.md.
  - id: run_all
    question: Which command runs all tests?
    scout: Find the command that runs the whole suite, from manifest scripts (npm test), the framework's default (dotnet test, pytest, cargo test, go test ./...), a Makefile target, or the CI config. Include setup it needs, such as a database or an environment variable, when the config shows it.
    options:
      - label: Detected command
        scouted: true
        description: Written as "All tests: `<command>`".
      - label: Skip
        value: ""
        description: Do not document a command for the whole suite.
  - id: run_related
    question: How do you run only the tests related to a change?
    scout: Look for runner support for changed-file or area selection (jest --findRelatedTests, vitest related, pytest-testmon, dotnet test --filter on a namespace or class, cargo test <module path>, go test ./<package>/...), or test files mirroring the source tree so the matching folder can be run. Report nothing if the project has no such route.
    options:
      - label: Detected approach
        scouted: true
        description: Written as "Tests for a change: <how to select them>".
      - label: Skip
        value: ""
        description: Do not document a related-tests route.
  - id: run_single
    question: How do you run a single test or test file?
    scout: Find the runner's filter syntax for one test, class or file (jest <path> -t "<name>", pytest <path>::<name>, dotnet test --filter "FullyQualifiedName~<name>", cargo test <name>, go test -run <Name> ./<pkg>).
    options:
      - label: Detected syntax
        scouted: true
        description: Written as "Single test: `<command with placeholders>`".
      - label: Skip
        value: ""
        description: Do not document single-test syntax.
  - id: run_split
    question: How do you run fast and slow tests separately?
    scout: Check whether the project separates unit tests from integration or end-to-end tests, through folders, projects, traits or categories, markers (pytest -m), tags, or separate scripts (test:unit, test:e2e). Report nothing if there is a single undivided suite.
    options:
      - label: Detected split
        scouted: true
        description: Written as "Fast vs slow: <how to run each>".
      - label: Skip
        value: ""
        description: Do not document a split.
---

## Testing

- {{layout}}
- {{run_all}}
- {{run_related}}
- {{run_single}}
- {{run_split}}
- When a test fails, fix the code. Change a test only when it is wrong or the requested behaviour changed, and say so. Never skip, delete or loosen a test to get it passing.
- Reproduce a bug with a failing test before fixing it, and keep that test.
- Ship tests with new or changed behaviour in the same change.
- Follow the project's existing test framework, layout, naming and helpers; do not introduce another framework or assertion library.
