# Agent Instructions

## Tooling
- `mise` is used for task management and tool versioning.
- `workspaced` is the designated linter/formatter aggregator.
  - **Note**: `bin/workspaced` is a local implementation that wraps `shellcheck` and `shfmt`. It requires `sqlite` (pinned version) and system dependencies like `zip`/`unzip` (which are typically available in CI).

## Tasks
- `mise run lint`: Lints the codebase using `workspaced`.
- `mise run fmt`: Formats the codebase using `workspaced`.
- `mise run test`: Runs the test suite (`tests/run_tests.sh`).
- `mise run ci`: Runs lint and test tasks.

## CI/CD
- GitHub Actions workflow is defined in `.github/workflows/autorelease.yml`.
- It handles installation, codegen, PR creation (if changes), CI checks, and release (on tag/dispatch).
