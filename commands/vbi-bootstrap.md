# vbi-bootstrap

Bootstrap a new project from an approved Notion PRD into a fully structured GitHub project.
One atomic operation: PRD → Milestones → Issues → Dependency Map → CLAUDE.md

## Usage
/vbi-bootstrap $ARGUMENTS

Arguments: PRD identifier and GitHub repo (e.g. "PRD-002 paulmona/my-repo")
If no arguments provided, ask for PRD first, then GitHub repo name.

## Pre-flight Check

1. Fetch the PRD from Notion using notion-fetch.
   Confirm Status = Approved and GitHub Ready = true before proceeding.
   If not approved, stop and tell the user to run /vbi-prd-ready first.

2. Confirm with user:
   "Ready to bootstrap [Project Name] into [repo]. This will create Milestones, Issues, a
   Dependency Map, and CLAUDE.md. Confirm?"

---

## Step 1: Create GitHub Milestones

For each numbered milestone section in the PRD, create a GitHub Milestone:

Title:       M[N]: [Milestone Name]
Description: [Milestone scope copied from PRD]
Due date:    Set if timeline specified in PRD, otherwise leave blank

---

## Step 2: Create GitHub Issues

For each milestone, decompose into discrete issues. Each issue must be:
- A single testable unit of work
- Completable in 1-4 hours of focused work
- Clear pass/fail outcome

Issue title format: [Imperative verb] [specific noun]
Good: "Write failing tests for lead scoring algorithm"
Good: "Implement lead scoring algorithm to pass tests"
Bad:  "Work on scoring" (too vague)
Bad:  "Various setup tasks" (too broad)

Note: For every build issue, create a paired test issue that is written FIRST.
The test issue must be the first commit on the branch — failing test before implementation.

### Issue Body Template

```
## Story
As a [role], I want [action] so that [outcome].

## Context
[1-2 sentences: why this matters and where it fits in the milestone]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]

## Definition of Done
- [ ] Failing test written first and committed before any implementation
- [ ] Implementation written to make test pass (Green)
- [ ] Code refactored while keeping tests green
- [ ] Full test suite passes — no regressions
- [ ] Happy path: 100% test coverage
- [ ] Non-happy path: 100% target (edge cases can be lower, document exceptions)
- [ ] Error states: 100% — every error state handled AND tested, no exceptions
- [ ] No commented-out code
- [ ] No hardcoded values — config or constants only
- [ ] Every TODO references a GitHub issue number
- [ ] Functions are single-responsibility
- [ ] No issue = no work started, no exceptions
- [ ] Merged via PR — issue closed on merge only, not before

## Dependencies
- Blocked by: #[issue number] — [reason] (or "None")
- Blocks: #[issue number] — [reason] (or "None")

## Notes
[Tool references, links to PRD section, implementation hints]
```

### Labels

Apply two labels to every issue:

Type (pick one):
- setup       — Environment, config, scaffolding, account creation
- build       — Core feature implementation
- test        — Test writing, test infrastructure
- integration — Connecting two systems (API, webhook, CRM)
- docs        — Documentation, CLAUDE.md, README
- bug         — Defect fixes
- chore       — Maintenance, dependency updates

Feature (pick one):
- F1, F2, F3... matching the PRD milestone/feature grouping

---

## Step 3: Create Dependency Map

Create a pinned GitHub Issue titled "📋 Dependency Map — [Project Name]" with this structure:

```
## Dependency Map — [Project Name]
Generated from [PRD name] on [date].
Issues in the same phase can run concurrently.

### Phase 1 — Foundation (no dependencies, fully parallelizable)
- #[N] [title]
- #[N] [title]

### Phase 2 — Core Build (requires Phase 1 complete)
- #[N] [title] (depends: #[N])
- #[N] [title] (depends: #[N], #[N])

### Phase 3 — Integration (requires Phase 2)
- #[N] [title] (depends: #[N])

### Phase 4 — Polish and Validation
- #[N] [title]
```

Pin this issue in the GitHub repo.

---

## Step 4: Scaffold CLAUDE.md

Check if a CLAUDE.md exists at the repo root. If not, generate one using this template,
populated with project-specific content inferred from the PRD tool decisions and tech stack:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Build & Run Commands

\`\`\`bash
[exact command to install dependencies]
[exact command to run the project]
[exact command to run all tests]
[exact command to run a single test file]
[exact command to lint]
\`\`\`

## Local Development Environment

### Prerequisites
[Tools, versions, install instructions — inferred from PRD tool decisions]

### Setup
[Step-by-step first-time setup]

### Troubleshooting
[Common errors and fixes]

## Architecture

[Component hierarchy or description — inferred from PRD]

### Key Directories
[Map of directories and what lives in each]

### Patterns
[Design patterns used in this project]

### Data Flow
[How data moves through the system]

## GitHub Workflow

- Milestones map to PRD milestone sections (M1, M2, M3...)
- Issues tagged by feature label (F1, F2, F3...) and type label
- Branch naming: feature/<issue-number>-short-description
- Commits reference issue numbers: Verb noun (#N)
- No issue = no work started, no exceptions
- Issues closed on merge only — never before

## Definition of Done

All work MUST follow TDD — no exceptions:

1. Red   — Write the failing test first. Commit it. It must fail before any implementation.
2. Green — Write minimum code to make the test pass.
3. Refactor — Clean up while keeping tests green.

An issue is done when ALL of the following are true:
- [ ] Failing test written first and committed before any implementation
- [ ] Implementation written to make test pass (Green)
- [ ] Code refactored while keeping tests green
- [ ] Full test suite passes — no regressions
- [ ] Happy path: 100% test coverage
- [ ] Non-happy path: 100% target (edge cases can be lower, document exceptions)
- [ ] Error states: 100% — every error state handled AND tested, no exceptions
- [ ] No commented-out code
- [ ] No hardcoded values — config or constants only
- [ ] Every TODO references a GitHub issue number
- [ ] Functions are single-responsibility
- [ ] No issue = no work started, no exceptions
- [ ] Merged via PR — issue closed on merge only, not before
```

Commit the CLAUDE.md to the repo root with message: "Add CLAUDE.md (#[first issue number])"

---

## Completion Summary

When all steps are done, output:

```
✅ [Project Name] bootstrapped successfully

Milestones:  [N] created
Issues:      [N] created
Labels:      [N] applied
Dep Map:     Pinned as issue #[N]
CLAUDE.md:   [Created / Already existed]

Next step: Run /vbi-next [repo] to see what to work on first.
```
