# pm-git-workflow

Quick reference for git and GitHub workflow conventions.
Use this to check branch naming, commit format, and PR rules, or preload it into agent
definitions so agents always follow the correct workflow.

## Usage
/pm-git-workflow

No arguments. Outputs the full git and GitHub workflow rules for reference.

## Git Rules — MANDATORY

- **NEVER merge directly to main** — all changes go through Pull Requests, no exceptions
- **NEVER run `git merge` into main** — use `gh pr create` to open a PR, then merge via GitHub
- **NEVER run `gh pr merge`** — merging PRs is the developer's responsibility, not the agent's
- Feature branches are merged to main ONLY via approved PR — merged by the human developer
- If you catch yourself about to merge to main or merge a PR, STOP immediately
- When work is complete: push the branch, create a PR with `gh pr create`, and leave it for review

## Staying Up to Date

- **Always sync before starting work** — run `git fetch origin && git pull origin main` before creating branches or starting any task
- **Always sync when resuming** — if resuming a session, fetch and pull main first. Remote may have changed since last session.
- **Check branch freshness** — before working on an existing branch, ensure it's up to date with main

## Branch Naming

```
feature/<issue-number>-short-description
```

Examples:
- `feature/12-lead-scoring-tests`
- `feature/13-lead-scoring-implementation`
- `feature/7-project-scaffolding`

## Commit Message Format

```
Verb noun (#issue-number)
```

Examples:
- `Add failing tests for lead scoring (#12)`
- `Implement lead scoring algorithm (#13)`
- `Set up project scaffolding (#7)`

## GitHub Workflow

- Milestones map to PRD milestone sections (M1, M2, M3...)
- Issues tagged by feature label (F1, F2, F3...) and type label
- No issue = no work started, no exceptions
- Issues closed on merge only — never before

## Label System

**Type labels (pick one):**
- setup — Environment, config, scaffolding, account creation
- build — Core feature implementation
- test — Test writing, test infrastructure
- integration — Connecting two systems (API, webhook, CRM)
- frontend — Frontend wiring, UI assembly, page building
- docs — Documentation, CLAUDE.md, README
- bug — Defect fixes
- chore — Maintenance, dependency updates

**Feature labels (pick one):**
- F1, F2, F3... matching the PRD milestone/feature grouping

**Severity labels (for bugs):** critical, high, low

**Priority labels (for enhancements):** high, medium, low
