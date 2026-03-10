# Project Conventions and Rules

This file (`AGENTS.md`) is the source of truth for project-specific conventions, tooling rules, and execution constraints.

## Core Tooling & Setup
- **`mise`**: Task management MUST be handled via `mise`. Tools must be pinned to specific versions in `mise.toml` without directly installing linters like `shellcheck` or `shfmt`.
- **`workspaced`**: Must be installed via `mise` using the `github:lucasew/workspaced` backend. Avoid manual installation of individual linters or local wrapper scripts.
- **Linting/Formatting**: Must be performed exclusively via `workspaced` (e.g., `workspaced codebase lint`). Direct linter execution is discouraged.

## CI/CD Pipeline
- The repository uses a single GitHub Actions workflow (`.github/workflows/autorelease.yml`) triggered by push (including tags), PR, and dispatch.
- Strict sequence: Checkout -> Setup mise -> Install -> Codegen -> PR (if changes) -> CI -> Release -> Artifacts.
- **Fallback Tasks**: In `mise.toml`, wildcard dependencies like `install:*`, `test:*`, and `codegen:*` should include hidden dummy fallback tasks (e.g., `[tasks."test:dummy"] hide = true run = "echo 'No tests'"`) to prevent `mise run` from failing if no matching subtasks are present.

## Architecture & Codebase Pointers
- **Project Goal**: A shell/AWK-based pipeline designed to transform Brazilian "Auxilio Emergencial" ZIP/CSV data into SQLite databases.
- `zipcat` -> Extracts `.csv` content directly from ZIP archives to stdout.
- `sqlify` & `sqlify.awk` -> The core data transformation logic. Converts specific CSV layouts into raw SQL `INSERT` commands.
- `sql2db` -> Simple CLI wrapper to execute raw SQL against a SQLite database file.
- `dbify_all_zips` -> The primary runner script. Orchestrates the pipeline (unzip -> sqlify -> sqlite) over a folder of ZIPs.

## General Guidelines
- **Artifact Management**: Generated test artifacts (e.g., zip files, SQLite databases) must be gitignored or cleaned up immediately to prevent repository bloat.
- **Error Handling**: All code paths handling unexpected errors must funnel through a centralized error-reporting function. Never call `console.error` directly at the call site if in TS/JS environments, or ensure scripts exit safely with appropriate stderr logs in bash.
