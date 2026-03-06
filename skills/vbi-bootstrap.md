# vbi-bootstrap

Bootstrap a new project from an approved Notion PRD and its TRD into a fully structured GitHub project.
One atomic operation: PRD + TRD → Milestones → Issues → Dependency Map → CLAUDE.md

## Usage
/vbi-bootstrap $ARGUMENTS

Arguments: PRD identifier and GitHub repo (e.g. "PRD-002 paulmona/my-repo")
If no arguments provided, ask for PRD first, then GitHub repo name.

## Pre-flight Check

1. Fetch the PRD from Notion using notion-fetch.
   Confirm Status = Approved and GitHub Ready = true before proceeding.
   If not approved, stop and tell the user to run /vbi-prd-ready first.

2. Fetch the TRD from Notion. The TRD is a child page of the PRD.
   Use notion-search or navigate the PRD's child pages to find the TRD.
   If no TRD is found, warn the user: "No TRD found as a child page of this PRD.
   Technical details in issues and CLAUDE.md will be inferred from the PRD only.
   Continue anyway?" If user declines, stop.

3. Confirm with user:
   "Ready to bootstrap [Project Name] into [repo] using PRD + TRD. This will create
   Milestones, Issues, a Dependency Map, and CLAUDE.md. Confirm?"

---

## Step 1: Create GitHub Milestones

For each numbered milestone section in the PRD, create a GitHub Milestone:

Title:       M[N]: [Milestone Name]
Description: [Milestone scope copied from PRD]
Due date:    Set if timeline specified in PRD, otherwise leave blank

---

## Step 2: Create GitHub Issues

For each milestone, decompose into discrete issues using both the PRD (what to build)
and the TRD (how to build it). Each issue must be:
- A single testable unit of work
- Completable in 1-4 hours of focused work
- Clear pass/fail outcome
- Informed by TRD technical constraints (data models, API contracts, infrastructure requirements)

Issue title format: [Imperative verb] [specific noun]
Good: "Write failing tests for lead scoring algorithm"
Good: "Implement lead scoring algorithm to pass tests"
Bad:  "Work on scoring" (too vague)
Bad:  "Various setup tasks" (too broad)

Note: For every build issue, create a paired test issue that is written FIRST.
The test issue must be the first commit on the branch — failing test before implementation.

### Issue Review Gate

Before creating issues in GitHub, present them to the user for review ONE MILESTONE AT A TIME.
For each milestone, display a summary table of the planned issues:

```
### M[N]: [Milestone Name] — [X] issues planned

| #  | Title                                      | Type  | Labels    |
|----|--------------------------------------------|-------|-----------|
| 1  | [Issue title]                              | test  | test, F1  |
| 2  | [Issue title]                              | build | build, F1 |
| ...| ...                                        | ...   | ...       |
```

Then ask the user to review with three options:
- **Approve** — Create all issues for this milestone as shown
- **Suggest changes** — User provides feedback; revise the issue list and re-present
- **Skip milestone** — Do not create issues for this milestone

If the user suggests changes, apply the feedback, re-present the updated table, and ask again.
Only create issues in GitHub after the user approves each milestone.
This ensures the user has full control over issue scope and content before anything is created.

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

## Technical Details (from TRD)
[Relevant data models, API contracts, infrastructure requirements, or technical
constraints from the TRD that apply to this issue. Omit if TRD not available.]

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
Generated from [PRD name] + [TRD name] on [date].
Issues in the same phase can run concurrently.
Technical dependencies sourced from TRD.

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
populated with project-specific content from the TRD (primary source for architecture,
tech stack, data models, and patterns) and the PRD (for milestones and feature context):

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
[Tools, versions, install instructions — from TRD tech stack, fallback to PRD tool decisions]

### Setup
[Step-by-step first-time setup — from TRD environment requirements]

### Troubleshooting
[Common errors and fixes]

## Architecture

[Component hierarchy or description — from TRD system architecture section]

### Key Directories
[Map of directories and what lives in each — from TRD project structure]

### Data Models
[Core data models and schemas — from TRD data model section]

### Patterns
[Design patterns used in this project — from TRD technical decisions]

### Data Flow
[How data moves through the system — from TRD data flow / integration architecture]

### API Contracts
[Key API endpoints and contracts — from TRD API design section, if applicable]

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
